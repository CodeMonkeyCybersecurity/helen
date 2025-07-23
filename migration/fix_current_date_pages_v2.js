const jwt = require('jsonwebtoken');
const http = require('http');
const fs = require('fs');

// Admin API key parts
const keyId = "687e137adb65b00001a55bbe";
const secret = "0d346b24dfa16f8dfe3b8a80acbd7475eeb205bd2957595fe5698b13a81048a5";

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
    const req = http.request(options, (res) => {
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

// Convert markdown to simple HTML for Ghost
function markdownToHtml(markdown) {
  // Replace the shortcode placeholder with the actual date
  let html = markdown.replace(
    /<!-- \s*UNKNOWN SHORTCODE: current[\s\S]*?<\/div>/g,
    '21 July 2025'
  );
  
  // Also replace any remaining {{< current-date >}} shortcodes
  html = html.replace(/{{< current-date >}}/g, '21 July 2025');
  
  // Convert basic markdown to HTML (simplified conversion)
  // Headers
  html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>');
  html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>');
  html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>');
  
  // Bold
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  
  // Links
  html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
  
  // Line breaks
  html = html.replace(/\n\n/g, '</p><p>');
  html = '<p>' + html + '</p>';
  
  return html;
}

// Read the converted pages data
function getPageContent() {
  const data = JSON.parse(fs.readFileSync('/Users/henry/Dev/helen/migration/converted/ghost_pages.json', 'utf8'));
  
  const pages = {
    'security-guides': data.find(p => p.url_path === '/resources/security-guides/'),
    'comparisons': data.find(p => p.url_path === '/resources/comparisons/'),
    'faq': data.find(p => p.url_path === '/resources/faq/')
  };
  
  return pages;
}

// Get current page data from Ghost
async function getPageData(pageId) {
  const token = generateToken();
  
  const getOptions = {
    hostname: 'localhost',
    port: 2368,
    path: `/ghost/api/admin/pages/${pageId}/`,
    method: 'GET',
    headers: {
      'Authorization': `Ghost ${token}`,
      'Accept-Version': 'v5.0'
    }
  };
  
  const result = await makeRequest(getOptions);
  return result.pages ? result.pages[0] : null;
}

// Update page in Ghost
async function updatePage(pageId, slug, content) {
  // First get the current page data to get updated_at
  const currentPage = await getPageData(pageId);
  if (!currentPage) {
    console.error(`Could not fetch current data for ${slug}`);
    return;
  }
  
  const token = generateToken();
  
  console.log(`Updating page ${slug}...`);
  
  // Convert content and prepare update data
  const htmlContent = markdownToHtml(content);
  
  const updateData = {
    pages: [{
      html: htmlContent,
      updated_at: currentPage.updated_at
    }]
  };
  
  // Update the page
  const putOptions = {
    hostname: 'localhost',
    port: 2368,
    path: `/ghost/api/admin/pages/${pageId}/`,
    method: 'PUT',
    headers: {
      'Authorization': `Ghost ${token}`,
      'Accept-Version': 'v5.0',
      'Content-Type': 'application/json'
    }
  };
  
  const result = await makeRequest(putOptions, updateData);
  
  if (result.pages && result.pages[0]) {
    console.log(`✓ Successfully updated ${slug}`);
    
    // Verify the update
    const verifyToken = generateToken();
    const verifyOptions = {
      hostname: 'localhost',
      port: 2368,
      path: `/ghost/api/admin/pages/${pageId}/?formats=html`,
      method: 'GET',
      headers: {
        'Authorization': `Ghost ${verifyToken}`,
        'Accept-Version': 'v5.0'
      }
    };
    
    const verifyResult = await makeRequest(verifyOptions);
    if (verifyResult.pages && verifyResult.pages[0].html.includes('21 July 2025')) {
      console.log(`✓ Verified: ${slug} now contains "21 July 2025"`);
    }
  } else {
    console.error(`✗ Failed to update ${slug}:`, result);
  }
}

// Main function
async function main() {
  console.log('Starting to fix pages with current date...\n');
  
  // Get page content from converted data
  const pageContent = getPageContent();
  
  // Pages to update with their Ghost IDs
  const pagesToUpdate = [
    { id: '687e13f2db65b00001a55d4c', slug: 'security-guides', data: pageContent['security-guides'] },
    { id: '687e13f0db65b00001a55d38', slug: 'faq', data: pageContent['faq'] },
    { id: '687e13f0db65b00001a55d33', slug: 'comparisons', data: pageContent['comparisons'] }
  ];
  
  for (const page of pagesToUpdate) {
    if (!page.data) {
      console.error(`Could not find content for ${page.slug}`);
      continue;
    }
    
    try {
      await updatePage(page.id, page.slug, page.data.content);
      // Add a small delay between updates
      await new Promise(resolve => setTimeout(resolve, 1000));
    } catch (error) {
      console.error(`Error updating ${page.slug}:`, error.message);
    }
  }
  
  console.log('\nUpdate process completed.');
}

// Run the update
main().catch(console.error);