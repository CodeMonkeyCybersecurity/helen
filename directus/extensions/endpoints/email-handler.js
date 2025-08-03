export default {
  id: 'email-handler',
  handler: (router, { services, exceptions, database }) => {
    const { MailService, ItemsService } = services;
    const { ServiceUnavailableException } = exceptions;

    // Send training confirmation email
    router.post('/send-training-confirmation', async (req, res) => {
      try {
        const mailService = new MailService({ schema: req.schema });
        
        // Get email template from Directus
        const templates = new ItemsService('email_templates', { schema: req.schema });
        const template = await templates.readOne('training-confirmation');
        
        if (!template) {
          throw new ServiceUnavailableException('Email template not found');
        }
        
        // Replace template variables
        let htmlContent = template.html_content;
        htmlContent = htmlContent.replace(/{{name}}/g, req.body.name);
        htmlContent = htmlContent.replace(/{{training_date}}/g, req.body.date);
        htmlContent = htmlContent.replace(/{{training_type}}/g, req.body.type);
        htmlContent = htmlContent.replace(/{{location}}/g, req.body.location || 'Online');
        
        // Send via Mailcow SMTP
        await mailService.send({
          to: req.body.email,
          subject: template.subject,
          html: htmlContent,
          text: htmlContent.replace(/<[^>]*>/g, '') // Strip HTML for text version
        });
        
        // Log the email send
        const emailLogs = new ItemsService('email_logs', { schema: req.schema });
        await emailLogs.createOne({
          recipient: req.body.email,
          template: 'training-confirmation',
          status: 'sent',
          sent_at: new Date()
        });
        
        res.json({ success: true, message: 'Confirmation email sent' });
      } catch (error) {
        console.error('Email send error:', error);
        res.status(500).json({ 
          success: false, 
          error: 'Failed to send email',
          details: error.message 
        });
      }
    });

    // Newsletter subscription endpoint
    router.post('/newsletter-subscribe', async (req, res) => {
      try {
        const { email, name, preferences } = req.body;
        
        // Save to Directus
        const subscribers = new ItemsService('newsletter_subscribers', { schema: req.schema });
        
        // Check if already subscribed
        const existing = await subscribers.readByQuery({
          filter: { email: { _eq: email } },
          limit: 1
        });
        
        if (existing.length > 0) {
          return res.json({ 
            success: true, 
            message: 'Already subscribed',
            status: 'existing' 
          });
        }
        
        // Create new subscriber
        const subscriber = await subscribers.createOne({
          email,
          name,
          preferences: preferences || ['general'],
          status: 'pending',
          subscribed_at: new Date(),
          confirmation_token: generateToken()
        });
        
        // Send confirmation email
        const mailService = new MailService({ schema: req.schema });
        const confirmUrl = `${process.env.PUBLIC_URL}/confirm-subscription?token=${subscriber.confirmation_token}`;
        
        await mailService.send({
          to: email,
          subject: 'Confirm your subscription to Code Monkey Cybersecurity',
          html: `
            <h2>Welcome to Code Monkey Cybersecurity!</h2>
            <p>Hi ${name || 'there'},</p>
            <p>Please confirm your subscription by clicking the link below:</p>
            <p><a href="${confirmUrl}" style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Confirm Subscription</a></p>
            <p>If you didn't request this, you can safely ignore this email.</p>
            <p>Best regards,<br>Code Monkey Cybersecurity Team</p>
          `
        });
        
        res.json({ 
          success: true, 
          message: 'Please check your email to confirm subscription' 
        });
      } catch (error) {
        console.error('Newsletter subscription error:', error);
        res.status(500).json({ 
          success: false, 
          error: 'Failed to process subscription' 
        });
      }
    });

    // Contact form handler
    router.post('/contact-form', async (req, res) => {
      try {
        const { name, email, phone, subject, message, service_interest } = req.body;
        
        // Save to database
        const contacts = new ItemsService('contact_submissions', { schema: req.schema });
        const submission = await contacts.createOne({
          name,
          email,
          phone,
          subject,
          message,
          service_interest,
          submitted_at: new Date(),
          status: 'new'
        });
        
        // Send notification to team
        const mailService = new MailService({ schema: req.schema });
        await mailService.send({
          to: process.env.TEAM_EMAIL || 'sales@cybermonkey.net.au',
          subject: `New Contact Form: ${subject}`,
          html: `
            <h3>New Contact Form Submission</h3>
            <p><strong>From:</strong> ${name} (${email})</p>
            <p><strong>Phone:</strong> ${phone || 'Not provided'}</p>
            <p><strong>Service Interest:</strong> ${service_interest || 'General inquiry'}</p>
            <p><strong>Message:</strong></p>
            <blockquote>${message}</blockquote>
            <p><a href="${process.env.PUBLIC_URL}/admin/content/contact_submissions/${submission.id}">View in Directus</a></p>
          `
        });
        
        // Send acknowledgment to submitter
        await mailService.send({
          to: email,
          subject: 'We received your message - Code Monkey Cybersecurity',
          html: `
            <h2>Thank you for contacting us!</h2>
            <p>Hi ${name},</p>
            <p>We've received your message and will get back to you within 1 business day.</p>
            <p>In the meantime, feel free to check out our <a href="https://cybermonkey.net.au/docs">documentation</a> for more information about our services.</p>
            <p>Best regards,<br>Code Monkey Cybersecurity Team</p>
          `
        });
        
        res.json({ success: true, message: 'Message sent successfully' });
      } catch (error) {
        console.error('Contact form error:', error);
        res.status(500).json({ 
          success: false, 
          error: 'Failed to send message' 
        });
      }
    });
  }
};

// Helper function to generate confirmation tokens
function generateToken() {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
}