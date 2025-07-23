const jwt = require('jsonwebtoken');
const https = require('http'); // Using http since it's localhost

// Admin API key parts
const keyId = "687e137adb65b00001a55bbe";
const secret = "0d346b24dfa16f8dfe3b8a80acbd7475eeb205bd2957595fe5698b13a81048a5";

// Pages to update
const pages = [
  { id: '687e13f2db65b00001a55d4c', slug: 'security-guides' },
  { id: '687e13f0db65b00001a55d38', slug: 'faq' },
  { id: '687e13f0db65b00001a55d33', slug: 'comparisons' }
];

// Generate JWT token
function generateToken() {
  const iat = Math.floor(Date.now() / 1000);
  const payload = {
    iat: iat,
    exp: iat + 300,
    aud: "/admin/"
  };
  
  const secretBuffer = Buffer.from(secret, 'hex');
  return jwt.sign(payload, secretBuffer, {
    algorithm: 'HS256',
    header: {
      alg: 'HS256',
      typ: 'JWT',
      kid: keyId
    }
  });
}

// Make HTTP request
function makeRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(body));
        } catch (e) {
          resolve(body);
        }
      });
    });
    
    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

// Update page content
async function updatePage(pageId, pageSlug) {
  const token = generateToken();
  
  // First, fetch the page
  console.log(`Fetching page ${pageSlug}...`);
  const getOptions = {
    hostname: 'localhost',
    port: 2368,
    path: `/ghost/api/admin/pages/${pageId}/?formats=lexical`,
    method: 'GET',
    headers: {
      'Authorization': `Ghost ${token}`,
      'Accept-Version': 'v5.0'
    }
  };
  
  const pageData = await makeRequest(getOptions);
  
  if (!pageData.pages || !pageData.pages[0]) {
    console.error(`Failed to fetch page ${pageSlug}`);
    return;
  }
  
  const page = pageData.pages[0];
  
  // Parse lexical content
  let lexicalContent;
  try {
    lexicalContent = JSON.parse(page.lexical);
  } catch (e) {
    console.error(`Failed to parse lexical content for ${pageSlug}`);
    return;
  }
  
  // Function to recursively update text nodes
  function updateTextNodes(node) {
    if (node.text && node.text.includes('{{< current-date >}}')) {
      node.text = node.text.replace(/{{< current-date >}}/g, '21 July 2025');
      return true;
    }
    
    // Also check for the converted shortcode placeholder
    if (node.text && node.text.includes('UNKNOWN SHORTCODE: current')) {
      // Find and replace the entire shortcode placeholder section
      node.text = node.text.replace(
        /<!-- \s*UNKNOWN SHORTCODE: current[\s\S]*?<\/div>/g,
        '21 July 2025'
      );
      return true;
    }
    
    if (node.children) {
      let updated = false;
      for (const child of node.children) {
        if (updateTextNodes(child)) {
          updated = true;
        }
      }
      return updated;
    }
    
    return false;
  }
  
  // Update the content
  const updated = updateTextNodes(lexicalContent.root);
  
  if (!updated) {
    console.log(`No current-date shortcode found in ${pageSlug}`);
    return;
  }
  
  // Prepare update data
  const updateData = {
    pages: [{
      lexical: JSON.stringify(lexicalContent),
      updated_at: page.updated_at
    }]
  };
  
  // Update the page
  console.log(`Updating page ${pageSlug}...`);
  const newToken = generateToken(); // Generate fresh token
  const putOptions = {
    hostname: 'localhost',
    port: 2368,
    path: `/ghost/api/admin/pages/${pageId}/`,
    method: 'PUT',
    headers: {
      'Authorization': `Ghost ${newToken}`,
      'Accept-Version': 'v5.0',
      'Content-Type': 'application/json'
    }
  };
  
  const result = await makeRequest(putOptions, updateData);
  
  if (result.pages && result.pages[0]) {
    console.log(`✓ Successfully updated ${pageSlug}`);
  } else {
    console.error(`✗ Failed to update ${pageSlug}:`, result);
  }
}

// Main function
async function main() {
  console.log('Starting to update pages with current date...\n');
  
  for (const page of pages) {
    try {
      await updatePage(page.id, page.slug);
    } catch (error) {
      console.error(`Error updating ${page.slug}:`, error.message);
    }
  }
  
  console.log('\nUpdate process completed.');
}

// Run the update
main().catch(console.error);