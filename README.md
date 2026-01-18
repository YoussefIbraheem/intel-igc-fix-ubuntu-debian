
# intel-igc-fix-ubuntu-debian

Fixes Intel `igc` network adapter not coming back after suspend / resume on Ubuntu.

This solution reloads the `igc` kernel driver automatically **after waking from sleep** using
a combination of:
- a systemd service (does the actual driver reload)
- a systemd sleep hook (triggers the service at the correct time)

---

## Problem

On some systems using the Intel `igc` Ethernet driver, the network interface
does not recover after suspend or hibernate.

Manually running:

```bash
sudo modprobe -r igc
sudo modprobe igc
````

fixes the issue — but doing this after every resume is not practical.

---

## Solution Overview

* `fix-igc-resume.service`

  * A systemd oneshot service that reloads the `igc` driver.

* `fix-igc-hook.sh`

  * A systemd sleep hook that runs **after resume** and restarts the service.
  * This guarantees the commands run at the correct moment (`post` resume).

This approach is more reliable than binding the service directly to `sleep.target`.

---

## Installation

### 1. Install the systemd service

```bash
sudo cp fix-igc-resume.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable fix-igc-resume.service
```

---

### 2. Install the system-sleep hook

```bash
sudo cp fix-igc-hook.sh /lib/systemd/system-sleep/
sudo chmod +x /lib/systemd/system-sleep/fix-igc-hook.sh
```

---

## Testing

You can test the service manually:

```bash
sudo systemctl restart fix-igc-resume.service
```

Then suspend and resume your system to confirm the network interface comes back automatically.

---

## Logs (optional)

To inspect logs related to the service:

```bash
journalctl -u fix-igc-resume.service
```

---

## Notes

* This fix applies to systems using the **Intel igc driver**
* Works with suspend, hibernate, and hybrid sleep
* No user interaction required after setup

---
