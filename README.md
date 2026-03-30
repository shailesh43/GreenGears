# GreenGears

> Project Testing

## 1. Android Report

- [x] AndroidManifest.xml: Application data can be backed up
- [x] Potential Data leak from clipboard - LIBRARY ISSUE
- [x] Insecure random number generator used - LIBRARY ISSUE
- [ ] Exported broadcast receiver and unprotected activities
- [x] Absence of Emulator detection & Min SDK (App can be installed on vulnerable patched android-v)
- [ ] Critical & High ones
    - [x] Absence of User Installed CA certificate
    - [ ] Root Detection
    - [x] MIME validation
    - [ ] Insecure web_auth & missing SSL pinning

## 2. iOS Report
- [ ] Cydia.app - Jailbreak detection missing
- [ ] Logout Functionality missing
- [ ] Screenshot detection missing
