from . import mail, celery
from flask_mail import Message
from flask import render_template, current_app as app
import logging


@celery.task
def send_async_email(message):
    try:
        mail.send(message)
        logging.info("An email has been sent.")
    except Exception as e:
        logging.error(f"Failed to send email: {e}")


def send_email(to, subject, template, **kwargs):
    try:
        message = Message(
            subject=f"{app.config['MAIL_SUBJECT_PREFIX']} {subject}",
            recipients=[to],
            body=render_template(f"{template}.txt", **kwargs),
            html=render_template(f"{template}.html", **kwargs)
        )
        
        # Gửi email bất đồng bộ
        send_async_email.delay(message)
        logging.info(f"Email to {to} is queued for sending.")
    except Exception as e:
        logging.error(f"Error creating email: {e}")