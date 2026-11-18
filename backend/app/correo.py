"""Envío de correos.

- Si existe BREVO_API_KEY -> se envía por la API HTTP de Brevo (funciona en Render gratis,
  que bloquea los puertos SMTP 25/465/587).
- Si no, se usa SMTP normal (para desarrollo local).
"""
import json
import os
import smtplib
import urllib.request
from email.mime.text import MIMEText


def enviar_email(destinatario: str, asunto: str, cuerpo: str) -> None:
    if not destinatario:
        return

    brevo_key = os.getenv("BREVO_API_KEY")
    remitente = os.getenv("MAIL_FROM") or os.getenv("SMTP_USER")

    if brevo_key:
        payload = {
            "sender": {"name": os.getenv("MAIL_FROM_NAME", "SENA Attendance"), "email": remitente},
            "to": [{"email": destinatario}],
            "subject": asunto,
            "textContent": cuerpo,
        }
        req = urllib.request.Request(
            "https://api.brevo.com/v3/smtp/email",
            data=json.dumps(payload).encode("utf-8"),
            headers={
                "api-key": brevo_key,
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=20) as resp:
            resp.read()
        return

    smtp_host = os.getenv("SMTP_HOST")
    if not smtp_host:
        print("Correo no enviado: falta BREVO_API_KEY o SMTP_HOST")
        return
    mensaje = MIMEText(cuerpo, "plain", "utf-8")
    mensaje["Subject"] = asunto
    mensaje["From"] = remitente
    mensaje["To"] = destinatario
    with smtplib.SMTP(smtp_host, int(os.getenv("SMTP_PORT", "587"))) as servidor:
        servidor.starttls()
        servidor.login(os.getenv("SMTP_USER"), os.getenv("SMTP_PASSWORD"))
        servidor.sendmail(remitente, [destinatario], mensaje.as_string())
