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

// Fix the content by replacing shortcodes
function fixContent(content) {
  // Replace the shortcode placeholder with the actual date
  let fixed = content.replace(
    /<!-- \s*UNKNOWN SHORTCODE: current[\s\S]*?<\/div>/g,
    '21 July 2025'
  );
  
  // Also replace any remaining {{< current-date >}} shortcodes
  fixed = fixed.replace(/{{< current-date >}}/g, '21 July 2025');
  
  return fixed;
}

// Convert markdown to mobiledoc with proper structure
function createMobiledoc(content) {
  const fixedContent = fixContent(content);
  
  return {
    version: "0.3.1",
    atoms: [],
    cards: [
      ["markdown", {
        cardName: "markdown",
        markdown: fixedContent
      }]
    ],
    markups: [],
    sections: [
      [10, 0]
    ],
    ghostVersion: "5.0"
  };
}

// Read the converted pages data
function getPageContent() {
  const data = JSON.parse(fs.readFileSync('/Users/henry/Dev/helen/migration/converted/ghost_pages.json', 'utf8'));
  
  return {
    'security-guides': data.find(p => p.url_path === '/resources/security-guides/'),
    'comparisons': data.find(p => p.url_path === '/resources/comparisons/'),
    'faq': data.find(p => p.url_path === '/resources/faq/')
  };
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

// Update page in Ghost with full content
async function updatePage(pageId, slug, pageData) {
  // First get the current page data to get updated_at
  const currentPage = await getPageData(pageId);
  if (!currentPage) {
    console.error(`Could not fetch current data for ${slug}`);
    return;
  }
  
  const token = generateToken();
  
  console.log(`\nUpdating page: ${pageData.title}`);
  console.log(`- Slug: ${slug}`);
  console.log(`- Content length: ${pageData.content.length} characters`);
  
  // Create mobiledoc from content
  const mobiledoc = createMobiledoc(pageData.content);
  
  // Prepare full update data
  const updateData = {
    pages: [{
      title: pageData.title,
      slug: slug,
      mobiledoc: JSON.stringify(mobiledoc),
      status: "published",
      meta_title: pageData.meta_title || pageData.title,
      meta_description: pageData.meta_description || null,
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
    
    // Wait a moment for Ghost to process
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Verify the update by checking for our date
    const verifyToken = generateToken();
    const verifyOptions = {
      hostname: 'localhost',
      port: 2368,
      path: `/ghost/api/admin/pages/${pageId}/?formats=html,mobiledoc`,
      method: 'GET',
      headers: {
        'Authorization': `Ghost ${verifyToken}`,
        'Accept-Version': 'v5.0'
      }
    };
    
    const verifyResult = await makeRequest(verifyOptions);
    if (verifyResult.pages && verifyResult.pages[0]) {
      const page = verifyResult.pages[0];
      const hasDate = (page.html && page.html.includes('21 July 2025')) || 
                      (page.mobiledoc && page.mobiledoc.includes('21 July 2025'));
      
      if (hasDate) {
        console.log(`✓ Verified: Page now contains "21 July 2025"`);
      } else {
        console.log(`⚠ Warning: Could not verify date in page content`);
      }
      
      // Check if content was actually saved
      const mobiledocObj = JSON.parse(page.mobiledoc || '{}');
      if (mobiledocObj.cards && mobiledocObj.cards.length > 0) {
        console.log(`✓ Content saved: ${mobiledocObj.cards[0][1].markdown.substring(0, 50)}...`);
      }
    }
  } else {
    console.error(`✗ Failed to update ${slug}:`, JSON.stringify(result, null, 2));
  }
}

// Main function
async function main() {
  console.log('=== Final Fix for Current Date Shortcode ===\n');
  console.log('This will update the following pages with "21 July 2025":\n');
  
  // Get page content from converted data
  const pageContent = getPageContent();
  
  // Pages to update with their Ghost IDs
  const pagesToUpdate = [
    { id: '687e13f2db65b00001a55d4c', slug: 'security-guides', data: pageContent['security-guides'] },
    { id: '687e13f0db65b00001a55d38', slug: 'faq', data: pageContent['faq'] },
    { id: '687e13f0db65b00001a55d33', slug: 'comparisons', data: pageContent['comparisons'] }
  ];
  
  console.log('Pages to update:');
  pagesToUpdate.forEach(page => {
    if (page.data) {
      console.log(`- ${page.data.title} (${page.slug})`);
    }
  });
  
  console.log('\nStarting updates...');
  
  for (const page of pagesToUpdate) {
    if (!page.data) {
      console.error(`\n✗ Could not find content for ${page.slug}`);
      continue;
    }
    
    try {
      await updatePage(page.id, page.slug, page.data);
      // Add delay between updates
      await new Promise(resolve => setTimeout(resolve, 2000));
    } catch (error) {
      console.error(`\n✗ Error updating ${page.slug}:`, error.message);
    }
  }
  
  console.log('\n=== Update Process Completed ===');
  console.log('\nThe following pages should now display "21 July 2025":');
  console.log('- Security Guides & Checklists (/security-guides/)');
  console.log('- Security Solution Comparisons (/comparisons/)');
  console.log('- Frequently Asked Questions (/faq/)');
}

// Run the update
main().catch(console.error);