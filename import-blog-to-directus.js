// Blog post importer for Directus
// Run this after creating the blog_posts collection in Directus

const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');
const fetch = require('node-fetch');

const DIRECTUS_URL = 'http://localhost:8055';
const EMAIL = 'admin@cybermonkey.net.au';
const PASSWORD = 'CyberMonkey2024!';

async function login() {
  const response = await fetch(`${DIRECTUS_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: EMAIL, password: PASSWORD })
  });
  const data = await response.json();
  return data.data.access_token;
}

async function importPost(token, post) {
  const response = await fetch(`${DIRECTUS_URL}/items/blog_posts`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(post)
  });
  return response.json();
}

async function main() {
  const token = await login();
  const blogDir = path.join(__dirname, 'content/blog');
  const files = fs.readdirSync(blogDir).filter(f => f.endsWith('.md') && f !== '_index.md');

  for (const file of files) {
    const filePath = path.join(blogDir, file);
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const { data, content } = matter(fileContent);
    
    const post = {
      title: data.title,
      slug: file.replace('.md', ''),
      description: data.description || '',
      content: content,
      author: data.author || 'Code Monkey Cybersecurity',
      categories: data.categories || [],
      tags: data.tags || [],
      status: 'published',
      date_published: data.date || new Date().toISOString()
    };
    
    console.log(`Importing: ${post.title}`);
    const result = await importPost(token, post);
    console.log(`Result:`, result.data ? 'Success' : 'Failed');
  }
}

// To run this:
// 1. npm init -y
// 2. npm install gray-matter node-fetch
// 3. node import-blog-to-directus.js