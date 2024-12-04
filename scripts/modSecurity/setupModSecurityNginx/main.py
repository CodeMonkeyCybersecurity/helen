from utils.dependencies import check_sudo, check_dependencies
from utils.nginx import install_nginx, get_nginx_version
from utils.modsecurity import install_libmodsecurity
from utils.owasp_crs import get_latest_crs_version
from utils.logging_config import configure_logging

def main():
    configure_logging()
    logging.info("Starting the script...")
    check_sudo()
    check_dependencies()
    install_nginx()
    nginx_version = get_nginx_version("/usr/local/src/nginx/")
    if nginx_version:
        logging.info(f"Nginx version detected: {nginx_version}")
    install_libmodsecurity()
    logging.info("Setup completed successfully.")

if __name__ == "__main__":
    main()
