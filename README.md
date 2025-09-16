# sessionkiller

**Tag it. Colour it. Freeze it. End it.**  
Your Termux sessions, under your complete control.

---

## 📜 About

`sessionkiller` is a colour‑coded, tag‑friendly process manager built for Termux.  
It gives you a clean, numbered menu of your running processes with live CPU/MEM stats,  
so you can kill, suspend, resume, or tag them in seconds — without hunting PIDs.

This is the **Official Northern Terpz Build** — hash‑protected to verify authenticity.  
Only builds from this repository are official.  
Redistribution or public modification is prohibited without permission.  
See [LICENSE](LICENSE) for full terms.

---

## ⚙ Requirements

- **Termux** (latest version from [F‑Droid](https://f-droid.org/) or GitHub)
- **Bash** (pre‑installed in Termux)
- **ps**, **grep**, **awk**, **sed** (pre‑installed in Termux)
- **inotify-tools** *(optional)* for auto‑update on save:
  ```bash
  pkg install inotify-tools

