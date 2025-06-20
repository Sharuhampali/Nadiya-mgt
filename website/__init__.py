from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from os import path
from flask_login import LoginManager

db = SQLAlchemy()
DB_NAME = "database.db"

import os
def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = '123!@#$%^&*'
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}'
    # app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:nadiya1@db.vmksginzzvobmolzcyzt.supabase.co:5432/postgres'
    # app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get("DATABASE_URL")
    db.init_app(app)

    from .views import views
    from .auth import auth

    app.register_blueprint(views, url_prefix='/')
    app.register_blueprint(auth, url_prefix='/')

    from .models import User
    
    with app.app_context():
        db.create_all()
        
    app.jinja_env.globals.update(enumerate=enumerate) 
    app.jinja_env.globals.update(str=str)
    app.jinja_env.globals.update(int=int)

    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(id):
        return User.query.get(int(id))
    
    @app.route('/healthz')
    def health():
        return "OK", 200

    return app


def create_database(app):
    if not path.exists('website/' + DB_NAME):
        db.create_all(app=app)
        print('Created Database!')