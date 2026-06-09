# GreenGears

> Project Testing

## 1. Android Report

- [x] AndroidManifest.xml: Application data can be backed up
- [x] Potential Data leak from clipboard - LIBRARY ISSUE
- [x] Insecure random number generator used - LIBRARY ISSUE
- [x] Exported broadcast receiver and unprotected activities
- [x] Production application signed in with debug
- [x] Absence of Emulator detection & Min SDK (App can be installed on vulnerable patched android-v)
- [x] Critical & High ones
    - [x] Absence of User Installed CA certificate
    - [x] Root Detection
    - [x] MIME validation
    - [x] Insecure web_auth & missing SSL pinning

## 2. iOS Report
- [x] Cydia.app - Jailbreak detection missing
- [x] Logout Functionality missing
- [x] Screenshot detection missing

## Distribution
- Release 1.0.1: Available on Play Store
- Release 1.0.1: Under Review for App Store