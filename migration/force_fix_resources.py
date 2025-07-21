#!/usr/bin/env python3
import requests
import json
import jwt
import time

GHOST_URL = "http://localhost:2368"
ADMIN_KEY = "687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22"

def get_auth_headers():
    key_id, key_secret = ADMIN_KEY.split(':')
    iat = int(time.time())
    payload = {'iat': iat, 'exp': iat + 300, 'aud': '/admin/'}
    token = jwt.encode(payload, bytes.fromhex(key_secret), algorithm='HS256', headers={'kid': key_id})
    return {'Authorization': f'Ghost {token}', 'Content-Type': 'application/json'}

# Resources page content from Hugo
resources_content = """# Resources

Welcome to our comprehensive cybersecurity resource center. We've organized our materials to help you strengthen your security posture, whether you're an individual, small business, or growing organization.

## 🛡️ Security Guides & Tools

### [Security Checklists](/resources/guides/)
Practical, actionable checklists for improving your cybersecurity posture. From password management to incident response planning.

### [Documentation Hub](/technical-documentation/)
Technical documentation for our tools and services, including API references and implementation guides.

## 🎓 Education & Training

### [Security Education Center](/resources/education/)
Learn about common cyber threats, best practices, and how to protect yourself and your organization.

### [Phishing Awareness Training](/resources/training/)
Interactive training modules to help you and your team recognize and avoid phishing attacks.

## 📊 Analysis & Comparisons

### [Security Solution Comparisons](/resources/comparisons/)
Unbiased comparisons of different security solutions to help you make informed decisions.

### [Case Studies](/resources/case-studies/)
Real-world examples of how organizations have improved their security posture.

### [FAQ](/resources/faq/)
Answers to common questions about cybersecurity, our services, and best practices.

## 🚀 Quick Links

- **[Get Started with Delphi](/sign-up/)** - Try our XDR solution
- **[Contact Our Team](/contact/)** - Get personalized assistance
- **[Browse Our Blog](/blog/)** - Latest security insights and updates

---

*Can't find what you're looking for? [Contact us](/contact/) and we'll help you find the right resources.*"""

# Get and update the page
headers = get_auth_headers()
response = requests.get(f"{GHOST_URL}/ghost/api/admin/pages/?filter=slug:resources", headers=headers)

if response.status_code == 200 and response.json()['pages']:
    page = response.json()['pages'][0]
    
    mobiledoc = {
        "version": "0.3.1",
        "atoms": [],
        "cards": [["markdown", {"markdown": resources_content}]],
        "markups": [],
        "sections": [[10, 0]]
    }
    
    update_data = {
        "pages": [{
            "mobiledoc": json.dumps(mobiledoc),
            "updated_at": page['updated_at']
        }]
    }
    
    update_response = requests.put(
        f"{GHOST_URL}/ghost/api/admin/pages/{page['id']}/",
        headers=headers,
        json=update_data
    )
    
    if update_response.status_code == 200:
        print("✅ Resources page fixed!")
        print("Visit: http://localhost:2368/resources/")
    else:
        print(f"❌ Failed: {update_response.text}")
else:
    print("❌ Could not find resources page")