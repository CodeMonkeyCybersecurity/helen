---
title: "Open Source Licensing"
description: "Our licensing strategy for ethical, open-source software at Code Monkey Cybersecurity"
---

# Open Source Licensing

At **Code Monkey Cybersecurity**, we believe open-source software should advance human dignity, digital autonomy, and social good. Our licensing choices reflect this philosophy.

We use and distribute our software under two key licenses:

---

## Do No Harm License

We use the [Do No Harm License](https://github.com/raisely/NoHarm) for projects where we want to:

- Promote ethical use of cybersecurity tools
- Prevent misuse by oppressive governments, fossil fuel giants, exploitative tech, or violent regimes
- Align with the [Universal Declaration of Human Rights](https://www.un.org/en/about-us/universal-declaration-of-human-rights)

### Do No Harm Features

- Based on permissive open-source licenses (MIT-style)
- Adds ethical usage restrictions to protect human rights, the environment, and democratic values
- Allows commercial use, modification, and redistribution — unless it supports harm

### Includes Do No Harm

- All infrastructure automation (e.g. Eos, deployment tooling)
- Code intended to interface with surveillance-sensitive environments (e.g. Vault, Wazuh agents)
- Projects primarily developed by Code Monkey Cybersecurity

---

## GNU General Public License v3 (GPLv3)

We use GPLv3 for projects where we want to:

- Ensure software remains free and open for all future users
- Require derivative works to also be open-source
- Prevent tivoization or closed hardware abuses

### GNU Features

- Strong copyleft: all modified versions must also be GPLv3
- No field-of-use restrictions
- Encourages a collaborative and open developer ecosystem

### Includes GNU

- Command-line tools (e.g. CLI for Delphi)
- SDKs or libraries that others might extend
- Any component where we want to guarantee software freedom

---

## License Compatibility

The **Do No Harm License is not GPL-compatible**, and vice versa.  
We never combine them in a single binary or linked product.

Instead:

- Each repository uses **only one license**
- Licenses are declared clearly in `LICENSE` and `README.md`
- We strongly prefer ethical licensing wherever possible, and default to Do No Harm when applicable

---

## Repository Policy

Every Code Monkey Cybersecurity GitHub repository includes:

- A clear `LICENSE` file (GPLv3 or Do No Harm)
- A `NOTICE` file for third-party attributions
- A `LICENSES/` directory if multiple components are involved
- A `go.mod`, `package.json`, or similar file declaring external dependencies

---

## Questions?

If you’re unsure whether a project is usable for your case (e.g. nonprofit, activist org, public school), reach out:

[main@cybermonkey.net.au](mailto:main@cybermonkey.net.au)

We're happy to clarify or provide a dual-license option where possible.

---

We believe open source should protect — not exploit.  
Thank you for building a better internet with us.
