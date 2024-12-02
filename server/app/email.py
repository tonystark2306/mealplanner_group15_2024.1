from . import celery, mail
from flask_mail import Message
from flask import render_template, current_app as app
import logging


@celery.task
def send_async_email(to, subject, text_body, html_body):
    message = Message(
        subject=subject,
        recipients=[to],
        body=text_body,
        html=html_body
    )
    mail.send(message)
    logging.info("An email has been sent.")


def send_email(to, subject, template, **kwargs):
    subject_prefixed = f"{app.config['MAIL_SUBJECT_PREFIX']} {subject}"
    text_body = render_template(f"{template}.txt", **kwargs)
    html_body = render_template(f"{template}.html", **kwargs)
    
    send_async_email.delay(to, subject_prefixed, text_body, html_body)