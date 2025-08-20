# Demo Page

a simple webpage with bootstrap, for building an action workflow on my server.



## Lokal Testen

1. Image bauen
```bash
docker build -t demo-page-image .
```
- `-t` demo-page → dein Image bekommt den Namen *demo-page*.
- `.` → aktuelles Verzeichnis als Build-Kontext.

2. Container starten
```bash
docker run -d --name demo-page-contianer -p 8008:80 demo-page-image
```
- `-d` → detached (läuft im Hintergrund).
- `-p 8080:80` → mappe lokalen Port 8080 auf Port 80 im Container (nginx).
- `--name mysite-container` → Container bekommt einen eindeutigen Namen.

3. Logs checken (falls was nicht geht)
```bash
docker logs demo-page-contianer
```

4. Browser
Browser öffnen mit [http://localhost:8008](http://localhost:8008) 
   ![demo-page.png](demo-page.png)

5. Container stoppen & löschen
```bash
docker stop demo-page-contianer
docker rm demo-page-contianer
```

---

## Secrets in GitHub anlegen

In deinem Repo: `Settings → Secrets and variables → Actions → New repository secret`.
Lege diese an (genau so benennen wie in der **demo-action.yml**):

- SSH_HOST – IP/Hostname deines Servers (z. B. 203.0.113.10)
- SSH_USER – z. B. ubuntu oder root
- SSH_PORT – optional, Standard 22
- SSH_PRIVATE_KEY – dein privater SSH-Key (RSA/ED25519). Der öffentliche Teil muss auf dem Server in ~/.ssh/authorized_keys stehen.
- GHCR_USER – dein GitHub-Username
- GHCR_PAT – ein Personal Access Token mit Scope read:packages (nur für den Server-Pull aus GHCR)

Hinweis: Zum Push des Images in GHCR benutzt der Workflow das eingebaute GITHUB_TOKEN (mit packages: write in den Workflow-Permissions).

### SSH-KEY Generieren

1. Key lokal erzeugen (auf irgendeinem PC)
```bash
ssh-keygen -t ed25519 -C "gh-actions-deploy-key" -f ~/.ssh/gh_actions_demopage -N ""
```
- Private Key: ~/.ssh/gh_actions_demopage
- Public Key: ~/.ssh/gh_actions_demopage.pub


2. Private Key als GitHub Secret hinterlegen
- Repo → Settings → Secrets and variables → Actions → **New repository secret**
- Name: `SSH_PRIVATE_KEY`
- Wert: kompletter Inhalt der Datei `~/.ssh/gh_actions_demopage`
  (inkl. `-----BEGIN OPENSSH PRIVATE KEY-----` … `-----END OPENSSH PRIVATE KEY-----`)


3. Public Key auf den Zielserver legen unter `~/.ssh/authorized_keys`.
```bash
ssh-copy-id -i ~/.ssh/gh_actions_demopage.pub <USER>@<HOST>
# Falls ssh-copy-id nicht funktioniert:
# cat ~/.ssh/gh_actions_demopage.pub | ssh <USER>@<HOST> \
# 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

### Github Contianer Registry (GHCR)

1. GHCR_USER – dein GitHub-Username anlegen
2. GHCR_PAT – ein Personal accass token erstellen.
- `GitHub → Settings (Profil) → Developer settings → Personal access tokens → Tokens (classic) → Generate new token (classic)`
- Scopes wählen: Für den Pull auf deinem Server reicht `read:packages`.(Nur wenn der Server auch pushen soll: zusätzlich `write:packages`; löschen benötigt `delete:packages`.)
- Als Secret hinterlegen: Im Repo unter Settings → Secrets and variables → Actions ein Secret GHCR_PAT anlegen und den kompletten Token einfügen.

