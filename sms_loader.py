"""
SMS Coupon Manager - Cloud Loader
Downloads and runs the encrypted application from cloud storage
"""

import os
import sys
import tempfile
import zipfile
import base64
import hashlib
import shutil

# ============================================================
#  CONFIGURATION - Edit this URL after uploading to cloud
# ============================================================
CLOUD_URL = "https://github.com/biker222/SMSCouponManager/raw/main/sms_package.enc"  # Replace with your download URL
PASSWORD = "TecnicaSMS2024"
# ============================================================

def download_file(url, dest):
    """Download file from URL"""
    import urllib.request
    import ssl

    # Try to handle HTTPS
    try:
        context = ssl.create_default_context()
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
    except:
        context = None

    # Handle different cloud services
    if 'drive.google.com' in url:
        # Convert Google Drive share link to direct download
        if '/file/d/' in url:
            file_id = url.split('/file/d/')[1].split('/')[0]
            url = f'https://drive.google.com/uc?export=download&id={file_id}'
        elif 'id=' in url:
            file_id = url.split('id=')[1].split('&')[0]
            url = f'https://drive.google.com/uc?export=download&id={file_id}'

    if 'dropbox.com' in url:
        # Convert Dropbox share link to direct download
        url = url.replace('www.dropbox.com', 'dl.dropboxusercontent.com')
        url = url.replace('?dl=0', '').replace('?dl=1', '')

    if 'onedrive.live.com' in url or '1drv.ms' in url:
        # OneDrive direct download conversion
        url = url.replace('redir?', 'download?')

    # Download
    if context:
        urllib.request.urlretrieve(url, dest, context=context)
    else:
        urllib.request.urlretrieve(url, dest)

def generate_key(password: str) -> bytes:
    key = hashlib.sha256(password.encode()).digest()
    return base64.urlsafe_b64encode(key)

def main():
    print("=" * 50)
    print("   SMS Coupon Manager - Cloud Edition")
    print("=" * 50)
    print()

    if CLOUD_URL == "https://github.com/biker222/SMSCouponManager/raw/main/sms_package.enc":
        print("ERROR: Cloud URL not configured!")
        print()
        print("Please edit sms_loader.py and set CLOUD_URL")
        print("to the download link for sms_package.enc")
        print()
        input("Press Enter to exit...")
        return

    # Install cryptography if needed
    try:
        from cryptography.fernet import Fernet
    except ImportError:
        print("Installing required packages...")
        os.system(f'"{sys.executable}" -m pip install cryptography --quiet')
        from cryptography.fernet import Fernet

    # Create temp directory
    temp_dir = tempfile.mkdtemp(prefix="sms_coupon_")

    try:
        # Download encrypted package
        print("Downloading application...")
        package_path = os.path.join(temp_dir, "package.enc")

        try:
            download_file(CLOUD_URL, package_path)
            print("Download complete.")
        except Exception as e:
            print(f"ERROR: Could not download: {e}")
            print()
            print("Please check:")
            print("  - Your internet connection")
            print("  - The cloud URL is correct")
            print("  - The file is publicly accessible")
            print()
            input("Press Enter to exit...")
            return

        # Decrypt
        print("Decrypting...")
        key = generate_key(PASSWORD)
        fernet = Fernet(key)

        with open(package_path, 'rb') as f:
            encrypted_data = f.read()

        try:
            decrypted_data = fernet.decrypt(encrypted_data)
        except Exception:
            print("ERROR: Decryption failed!")
            print("The package may be corrupted or the password is wrong.")
            print()
            input("Press Enter to exit...")
            return

        # Extract
        print("Extracting...")
        zip_path = os.path.join(temp_dir, "package.zip")
        with open(zip_path, 'wb') as f:
            f.write(decrypted_data)

        with zipfile.ZipFile(zip_path, 'r') as zf:
            zf.extractall(temp_dir)

        # Run the application
        print("Starting SMS Coupon Manager...")
        print()

        os.chdir(temp_dir)
        sys.path.insert(0, temp_dir)

        # Import and run
        exec(open(os.path.join(temp_dir, 'main.py')).read(), {'__name__': '__main__'})

    except Exception as e:
        print(f"ERROR: {e}")
        input("Press Enter to exit...")
    finally:
        # Cleanup - remove decrypted files
        try:
            shutil.rmtree(temp_dir)
        except:
            pass

if __name__ == "__main__":
    main()
