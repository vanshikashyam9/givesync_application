const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

// HTTP function v2 - requires Firebase Authentication
// Only authenticated users can call this function
exports.sendDonationSummary = onRequest(
  {
    cors: true,
    // Require authentication - only authenticated users can call
    invoker: "private", // This means only authenticated users can call it
  },
  async (req, res) => {
    console.log("Function invoked with data:", JSON.stringify(req.body));

    try {
      // Verify Firebase Authentication token
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        res.status(401).json({ 
          success: false, 
          error: "Unauthorized: Missing or invalid authentication token" 
        });
        return;
      }

      const idToken = authHeader.split("Bearer ")[1];
      let decodedToken;
      try {
        decodedToken = await admin.auth().verifyIdToken(idToken);
        console.log("Authenticated user:", decodedToken.email || decodedToken.uid);
      } catch (error) {
        console.error("Token verification failed:", error);
        res.status(401).json({ 
          success: false, 
          error: "Unauthorized: Invalid authentication token" 
        });
        return;
      }
      // For v2 functions, use environment variables or runtime config
      const config = {
        gmail: {
          email: process.env.GMAIL_EMAIL || "",
          password: process.env.GMAIL_PASSWORD || "",
        },
      };
      console.log("Firebase Config:", JSON.stringify(config));

      // Log config presence (do not log actual password)
      console.log("Gmail Config Present:", {
        email: !!config.gmail?.email,
        password: !!config.gmail?.password
      });

      if (!config.gmail || !config.gmail.email || !config.gmail.password) {
        res.status(500).json({ 
          success: false, 
          error: "Missing Gmail configuration. Set environment variables: GMAIL_EMAIL and GMAIL_PASSWORD" 
        });
        return;
      }

      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: config.gmail.email,
          pass: config.gmail.password,
        },
      });

      // HTTP functions receive data in req.body
      const requestData = req.body;
      const emailList = requestData.recipients;
      const report = requestData.report;

    console.log("Attempting to send email to:", emailList);

    if (!emailList || emailList.length === 0) {
      res.status(400).json({ 
        success: false, 
        error: "No recipients provided." 
      });
      return;
    }

    // Process attachments: decode base64 content if needed
    const attachments = [];
    if (requestData.attachments && Array.isArray(requestData.attachments)) {
      console.log(`Processing ${data.attachments.length} attachment(s)`);
      
      for (const attachment of requestData.attachments) {
        const processedAttachment = {
          filename: attachment.filename || "attachment",
        };

        // Handle base64-encoded content
        if (attachment.encoding === "base64" && attachment.content) {
          // Decode base64 string to Buffer
          processedAttachment.content = Buffer.from(attachment.content, "base64");
          processedAttachment.contentType = attachment.contentType || "text/csv";
          console.log(`Decoded base64 attachment: ${attachment.filename} (${processedAttachment.content.length} bytes)`);
        } else if (attachment.content) {
          // Direct content (string or Buffer)
          processedAttachment.content = attachment.content;
          processedAttachment.contentType = attachment.contentType || "text/csv";
          console.log(`Using direct content attachment: ${attachment.filename}`);
        } else {
          console.warn("Skipping attachment with no content:", attachment.filename);
          continue;
        }

        attachments.push(processedAttachment);
      }
      
      console.log(`Successfully processed ${attachments.length} attachment(s)`);
    } else {
      console.log("No attachments provided");
    }

    // Build dynamic subject with date range if provided
    let emailSubject = "Daily Donation Summary";
    if (requestData.dateRange) {
      emailSubject = `${requestData.dateRange} Donation Summary`;
    }

      const mailOptions = {
        from: `GiveSync <${config.gmail.email}>`,
        to: emailList,
        subject: emailSubject,
        text: report,
        html: requestData.html,
        attachments: attachments.length > 0 ? attachments : undefined,
      };

      await transporter.sendMail(mailOptions);
      console.log("Email sent successfully to:", emailList);
      res.status(200).json({ success: true });
    } catch (error) {
      console.error("Error sending email:", error);
      res.status(500).json({ 
        success: false, 
        error: `Email send failed: ${error.message}` 
      });
    }
  }
);

