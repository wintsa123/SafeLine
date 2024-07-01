
# SafeLine, the best free WAF for webmaster
<img src="https://raw.githubusercontent.com/chaitin/SafeLine/main/documents/static/images/403.svg" align="right" width="200" />

SafeLine is a web security gateway to protect your websites from attacks and exploits.

It defenses for all of web attacks, such as sql injection, code injection, os command injection, CRLF injection, ldap injection, xpath injection, rce, xss, xxe, ssrf, path traversal, backdoor, bruteforce, http-flood, bot abused and so on.

<p align="left">
  <a target="_blank" href="https://waf.chaitin.com/">🏠Home</a> &nbsp; | &nbsp;
  <a target="_blank" href="https://docs.waf.chaitin.com/">📖Documentation</a> &nbsp; | &nbsp;
  <a target="_blank" href="https://demo.waf.chaitin.com:9443/dashboard">🔍Live Demo</a> &nbsp; | &nbsp;
  <a target="_blank" href="https://waf-ce.chaitin.cn/">中文版</a>
</p>

<p align="left">
  <a target="_blank" href="https://discord.gg/wyshSVuvxC"><img src="https://img.shields.io/badge/Discord-5865F2?style=flat&logo=discord&logoColor=white"></a> &nbsp;
  <a target="_blank" href="https://x.com/safeline_waf"><img src="https://img.shields.io/badge/X-000000?style=flat&logo=x&logoColor=white"></a> &nbsp;
  <a target="_blank" href="https://t.me/safeline_waf"><img src="https://img.shields.io/badge/Telegram-2CA5E0?style=flat&logo=telegram&logoColor=white"></a> &nbsp;
  <a target="_blank" href="/documents/static/images/wechat-230825.png"><img src="https://img.shields.io/badge/WeChat-07C160?style=flat&logo=wechat&logoColor=white"></a>
</p>

# Screenshots

<img src="https://github.com/chaitin/SafeLine/images/safeline_en.png" width=600 />

# How It Works

<img src="/images/safeline-as-proxy.png" align="right" width=400 />

SafeLine is developed based on nginx, it serves as a reverse proxy middleware to detect and cleans web attacks, its core capabilities include:

- Defenses for web attacks
- Proactive bot abused defense 
- HTML & JS code encryption
- IP-based rate limiting
- Web Access Control List


## 自动部署

> 👍

```bash
bash -c "$(curl -fsSLk https://waf.chaitin.com/release/latest/setup.sh)"
```
群晖7.2安装输入命令
```bash
sudo bash -c "$(curl -fsSLk https://cdn.jsdelivr.net/gh/wintsa123/SafeLine/setup.sh)"
```


## 手动部署

to see [Documentation](https://docs.waf.chaitin.com/en/tutorials/install)
