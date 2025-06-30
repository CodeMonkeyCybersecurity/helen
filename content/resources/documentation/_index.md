# Welcome to our Knowledge Base Home

This is just a landing page where which you can use to touch off into each section of this knowledge base. 

You might find it helpful to return to this to use as a launching point into Athena, Eos or Hecate or any of the other projects we have.

For the main knowledge base, see [Athena](/Athena/Athena).

# The main characters:

## [Hecate](/Hecate/Hecate)

-   Frontend

Hecate, named after the ancient Greek goddess of crossroads, boundaries, and the arcane arts, Hecate stands as the gatekeeper between your infrastructure and the outside world.

Hecate is a modular reverse proxy framework aimed at helping humans set up their own reverse proxy.

## [Eos](/Eos/Eos)

-   Backend

In ancient Greek mythology and religion, Eos is the goddess and personification of the dawn, helping everyone start the day.

This repo contains lots of tools to help you get started on your ubuntu server journey, including tools for easy server management and turn-key web app configurations.

-   Includes [`Delphi`](/Eos/Delphi/Delphi) - powered by [Wazuh](/https://wazuh.com), an enterprise level security system.  
    Contains instructions and best practices for deploying and managing Wazuh within your infrastructure.

## [Persephone](/Persephone/Persephone)

-   Backups

Persephone is a solution designed to simplify and enhance the use of Restic for backups and recovery.

It provides additional features like cross platform compatibility, centralized management, automated scheduling, and modular configuration.

## [Athena](/Athena/Athena)

-   Knowledge Base

Athena is the Greek goddess of wisdom and practical reasoning. Accordingly, we think this is a fitting name for the repository of our how-to files and knowledge base.

Athena has comprehensive guides, tutorials, and documentation to help you navigate and utilize our cybersecurity solutions effectively.

## [Metis](/Metis/Metis)

-   Knowledge Base, specifically for Troubleshooting

Metis, the Greek goddess of wisdom, deep thought, and cunning. She was known for her resourcefulness and intelligence, making her an ideal symbol our troubleshooting knowledge base.

## [GitHub Repository](https://github.com/CodeMonkeyCybersecurity)

Access our GitHub repository to view source code, contribute, and report issues.

# Three part ecosystem

Our respoitories, including; [`Eos`](/Eos/Eos), [`Hecate`](/Hecate/Hecate), [`Persephone`](/Persephone/Persephone) are designed to help you set up your own self-hosted cloud infrastructure.

They are designed to be deployed together, **as an ecosystem**.

This means, they can be deployed **independently** of each other and can also **work together** to create your own self-hosted cloud deployment.

## [Hecate](/Hecate/Hecate): Frontend

### Reverse proxy

[Hecate GitHub](https://github.com/CodeMonkeyCybersecurity/hecate)  
Hecate was the ancient Greek goddess of crossroads, boundaries, and the arcane arts. This is a modular reverse proxy framework named after her, aimed at helping humans set up their own reverse proxies.

So today, Hecate still stands as the gatekeeper between your infrastructure and the outside world.

## [Eos](/Eos/Eos): Backend

### Tooling and backend Web Apps

[Eos GitHub](https://github.com/CodeMonkeyCybersecurity/eos)  
In ancient Greek mythology and religion, Eos is the goddess and personification of the dawn, helping everyone start the day. This repo contains lots of tools to help you get started on your ubuntu server journey.

-   [Delphi](/Eos/Delphi/Delphi)  
    Detailed instructions and best practices for deploying and managing Wazuh within your infrastructure.

See [here](/Eos/Eos) for other supported Web Applications

## [Persephone](/Persephone/Persephone): Backups

[Persephone GitHub](https://github.com/CodeMonkeyCybersecurity/persephone)  
Persephone is a solution designed to simplify and enhance the use of Restic for backups and recovery.

It provides additional features like cross platform compatibility, centralized management, automated scheduling, and modular configuration.

# Supported Web Apps

This section outlines what cloud-native web applications, which [`Eos`](/Eos/Eos) currently supports. Those currently marked 

X

means they aren't supported **yet**

## GitHub

The configurations to deploy these can be found in the [`eos/apps/`](https://github.com/CodeMonkeyCybersecurity/eos/tree/main/apps) directory

| Web application | Hecate | Eos | What is does | FQDN | Backend port |
| --- | --- | --- | --- | --- | --- |
| Static website | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | Static site | [domain.com](http://domain.com) | :8009 |
| Wazuh | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [XDR / SIEM](https://wazuh.com/) | [delphi.domain.com](http://delphi.domain.com) | :8011 |
| Mattermost | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Slack alternative](https://mattermost.com/) | [collaborate.domain.com](http://collaborate.domain.com) | :8017 :9017 |
| Nextcloud | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [iCloud /OneDrive alternative](https://nextcloud.com/) | [cloud.domain.com](http://cloud.domain.com) | :8039 |
| Mailcow | ![](/_assets/svg/twemoji/274c.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Email/groupware](https://mailcow.email/) | [mail.domain.com](http://mail.domain.com) | :8053 |
| Jenkins | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [CI/CD](https://jenkins.io/) | [jenkins.domain.com](http://jenkins.domain.com) | :8059 |
| Grafana | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Observability/monitoring](https://grafana.com/) | [observe.domain.com](http://observe.domain.com) | :8069 |
| ELK Stack | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [Search logs/metrics](https://www.elastic.co/) | [elk.domain.com](http://elk.domain.com) | :8081 |
| OpenStack | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [Azure, AWS, GCP alternative](https://www.openstack.org/) | [stack.domain.com](http://stack.domain.com) | :8087 |
| Nebula | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [Distributed mesh network](https://github.com/slackhq/nebula) | [mesh.domain.com](http://mesh.domain.com) | :8089 |
| Security Onion | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [Security monitoring](https://securityonionsolutions.com/) | [soc.domain.com](http://soc.domain.com) | :8093 |
| Restic | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Backups](https://restic.net/) | [persephone.domain.com](http://persephone.domain.com)<br><br>[persephoneapi.domain.com](persephoneapi.domain.com) | :8101 |
| Keycloak | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [Identity and access management](https://www.keycloak.org/) | [hera.domain.com](http://hera.domain.com) | :8111 |
| Theia | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [IDE](https://theia-ide.org/) | [code.domain.com](http://code.domain.com) | :8219 |
| Umami | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Privacy focussed web analytics](https://umami.is/) | [analytics.domain.com](http://analytics.domain.com) | :8117 |
| MinIO | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [S3 compatible object storage](https://min.io/) | [s3.domain.com](http://s3.domain.com)<br><br>[s3api.domain.com](s3api.domain.com) | :8123<br><br>:9123 |
| Penpot | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [UX design](https://github.com/penpot/penpot) | [penpot.domain.com](http://penpot.domain.com) | :8147 |
| Wiki.js | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Knowledge base/wiki](https://js.wiki/) | [wiki.domain.com](http://wiki.domain.com) | :8161 |
| ERPNext | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Enterprise Resource Planning (ERP)](https://erpnext.com/) | [erp.domain.com](http://erp.domain.com) | :8167 |
| Jellyfin | ![✅](/_assets/svg/twemoji/2705.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Media server](https://jellyfin.org/) | [media.domain.com](http://media.domain.com) | :8171<br><br>:9171 |
| Vault | ![](/_assets/svg/twemoji/274c.svg) | ![✅](/_assets/svg/twemoji/2705.svg) | [Secrets Management](https://github.com/hashicorp/vault) | [pandora.domain.com](http://pandora.domain.com) | :8179 |
| Consul | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | [Service Networking](https://github.com/hashicorp/consul) | N/A | :8191 :8209 |
| Open WebUI | ![](/_assets/svg/twemoji/274c.svg) | ![](/_assets/svg/twemoji/274c.svg) | Chatbot with WebUI | N/A | :8231 |
| Zabbix |     |     | [Monitoring](https://www.zabbix.com) | z.domain.com | • 8233<br><br>• 8237 |
| Shuffle |     |     | SOAR | s.domain.com | :80 → **8243**<br><br>:443 → <br><br>**8263** |

# Diagrams

Cloud servers are made out to be super complicated or mysterious. Essentially, they are made of three main parts:

1.  Frontend
2.  Backend
3.  Backups

The three tools here [`Hecate`](/Hecate), [`Eos`](/Eos), and [`Persephone`](/Persephone) are help set up these three different components.

## [Hecate](/Hecate)

will help you set and manage the frontend. The more technical term for 'frontend' is `reverse proxy`. This frontend will have a public IP address and will be the only part of your setup which will be directly accessible from the internet.

This means, once this is set up properly, you will be able to go on to Google, Safari or Firefox and type in `yourwebsitename.com`, and you will get sent here.

As an analogy, say you have an ex or a former friend or colleage who you'd rather not talk to anymore because you don't trust them. But say that you needed to talk to them. You might not want to talk to them directly. Instead, you might get a trusted friend to act as a messenger between the two of you. In this situation, your friend is acting as a proxy for you. And the person you don't want to talk to directly, is the internet.

In the context of cloud servers we call the machine that acts as this in-between messenger a `reverse proxy`. The reason we call it specifically a `reverse proxy` and not just a proxy is a bit more technical, but if you just remember that a `reverse proxy` acts as a trusted messenger who carries messages between you and the internet , you will get the main point. You can think of `Hecate` as your `reverse proxy` - your in between messenger between your backend servers and the untrusted internet.

While this is not strictly correct and technically `Hecate` is only a tool to help you set up and manage the `Nginx` reverse proxy, thinking of `Hecate` as the reverse proxy itself may be easier.

## [Eos](/Eos)

Eos will help you set up and manage the **backend** of your cloud server. While the reverse proxy acts only as a messenger, this backend server is where the magic happens. This backend server is what actually hosts the information/application/process/website/pages/programme you want to set up in the cloud. This information/application/process/website/pages/programme could be a place to store your files and photos (like iCloud, Google Cloud or Nextcloud), serve your emails from (eg. Microsoft exchange or Mailcow), keep track of the security of your network (Wazuh/Delphi), or host your wiki (like wikipaedia or wiki.js). In any case, this is where the 'thinking' for your cloud server happens in each of these examples.

As above, it may be easier to think of this backend as `Eos` itself, even though `Eos` is only a tool to set up and manage these backend applications.

In the example above about you, your trusted friend (`Hecate`), and your ex (*The Internet*), you would be `Eos`. You would make it known that if anyone wanted to talk to you, they would have to do it through your friend, `Hecate`. Your ex, *The Internet*, would go to your friend, `Hecate`, with a specific request. `Hecate` then comes to you with what they said. You, as `Eos`, have to listen to what `Hecate` has told you, and then you have to think about what to do/say in response to your ex. You, `Eos`, then give that response to your friend, `Hecate`, who then takes your message to your ex, *The Internet*, and delivers it to them.

This is an bizarre analogy to read, and it was even more bizarre to write down. But, we think it gets the point across of the main functionality of how cloud servers work. If you get confused, we recommend coming back to these three main actors:

-   `The Internet`, your ex, who you don't trust, is toxic, and you want to limit interraction with as much as possible.
-   `Hecate`, your trusted friend, the proxy, who acts as a messenger between you, `Eos` and your ex, *The Internet*.
-   `Eos`, you, the backend cloud server, which does all the thinking. You have to listen to Hecate, think about what she tells you, before giving your reply back to her for her to return to your ex.

There is a more in-depth diagram later on, but here is a very simple diagram to help clarify the common terminology, the more technical terms, and `Eos` and `Hecate`.

```plaintext
#
#        Common terms                  More technical                     Our stuff                   The story
#   ---------------------           ---------------------            ------------------          ------------------
#          Internet            #          Client              #          Internet            #          You ex
#             ^                #             ^                #             ^                #             ^
#             |                #             |                #             |                #             |
#             v                #             v                #             v                #             v
#      ┌─────────────┐         #      ┌───────────────┐       #        ┌────────┐            #        ┌─────────────┐
#      |  Frontend   |         #      | Reverse Proxy |       #        | Hecate |            #        | Your friend |
#      └─────────────┘         #      └───────────────┘       #        └────────┘            #        └─────────────┘
#             ^  |             #             ^  |             #             ^  |             #             ^  |
#             |  +------+      #             |  +------+      #             |  +---+         #             |  +---+
#             v         |      #             v         |      #             v      |         #             v      |
#        ┌─────────┐    |      #      ┌─────────────┐  |      #          ┌─────┐   |         #          ┌─────┐   | 
#        | Backend |    |      #      | Virtualhost |  |      #          | Eos |   |         #          | You |   |
#        └─────────┘    |      #      └─────────────┘  |      #          └─────┘   |         #          └─────┘   |
#             |  +------+      #             |  +------+      #             |  +---+         #             |  +---+
#             |  |             #             |  |             #             |  |             #             |  |
#             v  v             #             v  v             #             v  v             #             v  v
#        ┌─────────┐           #        ┌─────────┐           #       ┌────────────┐         #       ┌────────────┐
#        | Backups |           #        | Backups |           #       | Persephone |         #       | Persephone |
#        └─────────┘           #        └─────────┘           #       └────────────┘         #       └────────────┘
#             |                #             |                #             |                #             |
#             v                #             v                #             v                #             v
#     ┌────────────────┐       #     ┌────────────────┐       #     ┌────────────────┐       #     ┌────────────────┐
#     | Offline backup |       #     | Offline backup |       #     | Offline backup |       #     | Offline backup |
#     └────────────────┘       #     └────────────────┘       #     └────────────────┘       #     └────────────────┘
#
```

There are several diagrams which are more broad and more details throughout this documentation, but this is the overall structure and should be your reference when things become confusing.

## How do I use these repositories?

These repositories are best used together.

The `Hecate` project sets up an [NGINX](https://nginx.org/en/) web server as a reverse proxy using `docker compose`. The aim is to make deploying cloud native Web Apps on your own infrastructure as 'point and click' as possible. The `reverse proxy` set up here can be used in front of the corresponding web application/backend deployed by the [`Eos`](/Eos) repository.

Below is a slightly more technical version of the diagram above outlining how things work 'under the hood', more explicitly:

```plaintext
#
#                         ┌───────────────────────────┐
#                         │         Clients           │    # This is how your cloud instance will be
#                         │ (User Browsers, Apps, etc)│    # accessed. Usually a browser on a client
#                         └────────────┬──────────────┘    # machine.
#                                      │
#                                      ▼
#                         ┌───────────────────────────┐
#                         │       DNS Resolution      │    # This needs to be set up
#                         │ (domain.com,              |    # with your cloud provider or DNS broker, eg.
#                         | cybermonkey.net.au, etc.) │    # GoDaddy, Cloudflare, Hetzner, etc.
#                         └────────────┬──────────────┘
#                                      │
#                                      ▼
#
#        **This your remote server (reverse proxy/proxy/cloud instance)**
#
#                          #########################
#                          #  Hecate sets this up  #
#                          #########################
#
#                           ┌─────────────────┐    
#                           │   Reverse Proxy │    # This is what we are setting up `hecate`.
#                           │ (NGINX, Caddy,  │    # All your traffic between the internet and
#                           │   Ingress, etc) │    # the backend servers gets router through
#                           └────────┬────────┘    # here.
#  			                            │
#   		    ┌────────────────────────┼─────────────────────────┐
#   		    │                        │                         │
#   		    ▼                        ▼                         ▼
#
#      **These are your local servers (backend/virtual hosts)**
#
#                    #######################
#                    #  Eos sets these up  #
#                    #######################
#
#	┌──────────────┐       ┌──────────────┐          ┌──────────────┐
#	│  Backend 1   │       │  Backend 2   │          │  Backend 3   │
#	│  (backend1)  │       │  (backend2)  │          │  (backend3)  │    # If using tailscale,
#	│  ┌────────┐  │       │  ┌────────┐  │          │  ┌────────┐  │    # these are the magicDNS hostnames.
#	│  │ Service│  │       │  │ Service│  │          │  │ Service│  │    # For setting up a demo website instance, 
#	│  │ Pod/   │  │       │  │ Pod/   │  │          │  │ Pod/   │  │    # see our `helen` repository
#	│  │ Docker │  │       │  │ Docker │  │          │  │ Docker │  │    # To set up Wazuh, check out
#	│  │  (eg.  │  │       │  │  (eg.  │  │          │  │  (eg.  │  │    # eos/legacy/wazuh/README.md.
#	│  │Website)│  │       │  │ Wazuh) │  │          │  │Mailcow)│  │    #
#	│  └────────┘  │       │  └────────┘  │          │  └────────┘  │    #
#	└──────────────┘       └──────────────┘          └──────────────┘    #
#
#
#      							**This is your backup server**
#
#                    ##############################
#                    #  Persephone sets this up  #
#                    ##############################
#
#												┌──────────────┐  
#												│  Persephone  │
#												│  ┌────────┐  │
#												│  │ Backup │  │
#												│  │ server │  │
#												│  └────────┘  │
#												└──────────────┘
#
```

## Features

-   Lightweight `NGINX` container based on the `nginx` `docker` image.
-   Automatic `HTTPS` certificate generation using `Certbot`.
-   Support for serving custom static files from the `html` directory, for a landing page/website
-   Automatic redirection from `HTTP` to `HTTPS`.
-   `docker compose` for easy deployment and management.
-   Accessible on the web, via domain name (eg. `domain.com`) pointing to your server’s IP address (eg. `12.34.56.78`) and any subdomains ( eg. `sub.domain.com`) as needed

## Simple Diagram

Here is a more simple diagram than the one above

```plaintext
#                       User  # The user accesses these web apps by googling `domain.com` 
#                        ^    # or `nextcloud.domain.com`
#                        |
#                        v
#                 ┌─────────────┐  # Deployed by `hecate`
#                 |Reverse Proxy|  # This is your remote cloud server
#                 └─────────────┘  # 
#                        ^   |
#                        |   +-------------------------------------------------------+
#                        v                                                           |
#       +----------------+---------------+                                           |
#       ^                ^               ^                                           |
#       |                |               |                                           |
#       v                v               v                                           |
#  ┌──────────────┐ ┌───────────┐ ┌───────────┐ # Deployed by `eos`                  |
#  | HTML website | | Nextcloud | | Wazuh     | # These are your local server(s)     |
#  └──────────────┘ └───────────┘ └───────────┘ #                                    |
#       |                |               |                                           |
#       v                v               v                                           |
#       +----------------+---------------+                                           |
#                        |                                                           |
#                        |  +--------------------------------------------------------+
#                        |  |
#                        v  v
#                ┌──────────────┐ # All nodes are backed up to `persephone`  
#                │  Persephone  │ # Make this a separate physical server on its own
#                └──────────────┘
#                        |
#                        v 
#                ┌──────────────┐ # Back up to here weekly
#                │    Offline   │ # Make sure this is offline when it's not being used
#                │    storage/  │
#                │    backup    │
#                └──────────────┘
#
```

**More to come regarding distributed, highly available, and kubernetes-based deployments.**

## To set up a reverse proxy:

[Hecate](/Hecate)  
Hecate, named after the ancient Greek goddess of crossroads, boundaries, and the arcane arts, Hecate stands as the gatekeeper between your infrastructure and the outside world.

Hecate is a modular reverse proxy framework aimed at helping humans set up their own reverse proxy.

Here is a snapshot from the diagram above, focussing on the part `hecate` is responsible for

```plaintext
#
#                       ...
#                        ^    
#                        |
#                        v
#                 ┌─────────────┐  # Deployed by `hecate`
#                 |Reverse Proxy|  # This is your remote cloud server
#                 └─────────────┘  # 
#                        ^ 
#                        |   
#                        v
#       +----------------+---------------+
#       ^                ^               ^
#       |                |               |
#       v                v               v   
#      ...              ...              ...
#
```

## To set up a virtual host:

[Eos](/Eos)  
In ancient Greek mythology and religion, Eos is the goddess and personification of the dawn, helping everyone start the day. This repo contains lots of tools to help you get started on your ubuntu server journey.

```plaintext
#
#      ...              ...             ...
#       |                |               |
#       v                v               v
#  ┌──────────────┐ ┌───────────┐ ┌───────────┐ # Deployed by `eos`
#  | HTML website | | Nextcloud | | Wazuh     | # These are your local server(s)
#  └──────────────┘ └───────────┘ └───────────┘ #
#       |                |               |
#      ...              ...             ...
#
```

## To set up your backups:

[Persephone](/Persephone)  
Persephone is a solution designed to simplify and enhance the use of Restic for backups and recovery.

```plaintext
#
#                      ... ...
#                       |   |
#                       v   v
#                ┌──────────────┐ # All nodes are backed up to `persephone`  
#                │  Persephone  │ # Make this a separate physical server on its own
#                └──────────────┘
#                        |
#                       ...
#
```

## Offline storage / archiving

This isn't super complicated and is probably a little out of our scope here, so we're going to leave this up to you.

```plaintext
#                       ...
#                        |
#                        v
#                ┌──────────────┐ # Back up to here weekly
#                │    Offline   │ # Make sure this is offline when it's not being used
#                │    storage/  │
#                │    backup    │
#                └──────────────┘
#
```

# Other links

Return to the main website [cybermonkey.net.au](https://cybermonkey.net.au/)

Our [Facebook](https://www.facebook.com/codemonkeycyber)

Or [X/Twitter](https://x.com/codemonkeycyber)

# Complaints, compliments, confusion:

Secure email: [main@cybermonkey.net.au](mailto:main@cybermonkey.net.au)  
Website: [cybermonkey.net.au](https://cybermonkey.net.au)

```plaintext
#     ___         _       __  __          _
#    / __|___  __| |___  |  \/  |___ _ _ | |_____ _  _
#   | (__/ _ \/ _` / -_) | |\/| / _ \ ' \| / / -_) || |
#    \___\___/\__,_\___| |_|  |_\___/_||_|_\_\___|\_, |
#                  / __|  _| |__  ___ _ _         |__/
#                 | (_| || | '_ \/ -_) '_|
#                  \___\_, |_.__/\___|_|
#                      |__/
```

---

© 2025 [Code Monkey Cybersecurity](https://cybermonkey.net.au/). ABN: 77 177 673 061. All rights reserved.