from flask import Flask, render_template, request, redirect, flash, url_for, Response, abort, session
import requests
from urllib.parse import urlparse
import os
from functools import wraps

app = Flask(__name__)
app.secret_key = "SECRET_KEY"

RAILS_API_BASE = "https://albumtrackerca.onrender.com/api"
RAILS_API = f"{RAILS_API_BASE}/albums"
API_ORIGIN = f"{urlparse(RAILS_API).scheme}://{urlparse(RAILS_API).hostname}"

def get_auth_headers():
    token = session.get('jwt_token')
    if token:
        return {'Authorization': f'Bearer {token}'}
    return {}

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'jwt_token' not in session:
            flash('Please log in to access this page.', 'warning')
            return redirect(url_for('login_page')) 
        return f(*args, **kwargs)
    return decorated_function

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'jwt_token' not in session:
            flash('Please log in to access this page.', 'warning')
            return redirect(url_for('login_page'))
        if session.get('user_role') != 'admin':
            flash('Admin access required.', 'danger')
            return redirect(url_for('albums_index'))
        return f(*args, **kwargs)
    return decorated_function

@app.route("/")
def root():
    return redirect(url_for("albums_index"))

# Index/Home
@app.route("/albums")
@login_required
def albums_index():
    query = request.args.get("q")
    params = {"q": query} if query else {}
    
    # Send auth headers with the request
    headers = get_auth_headers()
    response = requests.get(RAILS_API, params=params, headers=headers)
    
    if response.status_code == 401:
        session.clear()
        flash('Session expired or unauthorized access.', 'danger')
        return redirect(url_for('login_page'))
    
    albums = response.json() if response.status_code == 200 else []
    
    return render_template("albums/index.html", albums=albums, query=query)

# View Album Details
@app.route("/albums/<int:album_id>")
@login_required
def albums_show(album_id):
    response = requests.get(f"{RAILS_API}/{album_id}", headers=get_auth_headers())
    if response.status_code == 200:
        album = response.json()
    else:
        flash(f"Album not found.", "danger")
        return redirect(url_for("albums_index"))
    
    return render_template("albums/show.html", album=album)

# New Album
@app.route("/albums/new")
@admin_required
def albums_new():
    album = {
        "title": "",
        "artist": "",
        "release_year": "",
        "genre": "",
        "rating": 0,
        "availability": False
    }
    return render_template("albums/new.html", album=album)

# Create
@app.route("/albums", methods=["POST"])
@admin_required
def albums_create():
    album_data = {
        "title": request.form["title"],
        "artist": request.form["artist"],
        "release_year": request.form["release_year"],
        "genre": request.form["genre"],
        "rating": request.form["rating"],
        "availability": "availability" in request.form
    }

    files = {}
    if "cover_image" in request.files and request.files["cover_image"].filename:
        files["album[cover_image]"] = request.files["cover_image"]

    if files:
        # Flask's requests post data fields need to be structured correctly for file uploads
        data = {f"album[{k}]": v for k, v in album_data.items()}
        # Use files dict directly, no need for JSON headers
        response = requests.post(RAILS_API, headers=get_auth_headers(), data=data, files=files) 
    else:
        # JSON post for data-only updates
        response = requests.post(
            RAILS_API,
            headers=get_auth_headers(),
            json={"album": album_data}
        )
    
    if response.status_code == 201:
        flash("Album created successfully!", "success")
    else:
        try:
            errors = response.json().get('errors', [f'Creation failed: {response.status_code}'])
        except:
            errors = [f'Creation failed: {response.status_code} - {response.text[:200]}']
        
        for error in errors:
            flash(f"Failed to create album: {error}", "danger")

    return redirect(url_for("albums_index"))

# Edit
@app.route("/albums/<int:album_id>/edit")
@admin_required
def albums_edit(album_id):
    response = requests.get(f"{RAILS_API}/{album_id}", headers=get_auth_headers())
    if response.status_code == 200:
        album = response.json()
        return render_template("albums/edit.html", album=album)
    else:
        flash(f"Album not found or access denied.", "danger")
        return redirect(url_for("albums_index"))

# Update
@app.route("/albums/<int:album_id>/update", methods=["POST"])
@admin_required
def albums_update(album_id):
    album_data = {
        "title": request.form["title"],
        "artist": request.form["artist"],
        "release_year": request.form["release_year"],
        "genre": request.form["genre"],
        "rating": request.form["rating"],
        "availability": "availability" in request.form
    }

    # If an image is uploaded → multipart
    if "cover_image" in request.files and request.files["cover_image"].filename:
        files = {
            "album[cover_image]": request.files["cover_image"]
        }
        data = {f"album[{k}]": v for k, v in album_data.items()}
        
        response = requests.put(
            f"{RAILS_API}/{album_id}",
            headers=get_auth_headers(),
            data=data,
            files=files
        )
    else:
        json_data = {"album": album_data}
        response = requests.put(
            f"{RAILS_API}/{album_id}",
            headers=get_auth_headers(),
            json=json_data
        )

    if response.status_code in [200, 204]:
        flash("Album updated successfully!", "success")
    else:
        flash(f"Failed to update album: {response.text}", "danger")

    return redirect(url_for("albums_show", album_id=album_id))

# Delete
@app.route("/albums/<int:album_id>/delete", methods=["POST"])
@admin_required
def albums_delete(album_id):
    response = requests.delete(f"{RAILS_API}/{album_id}", headers=get_auth_headers())
    if response.status_code in [200, 204]:
        flash("Album deleted successfully!", "success")
    else:
        flash(f"Failed to delete album: {response.text}", "danger")
    return redirect(url_for("albums_index"))

# ==================== Authentication Routes ====================

# Register Page
@app.route("/register", methods=["GET"])
def register_page():
    if 'jwt_token' in session:
        return redirect(url_for("albums_index"))
    return render_template("register.html")

# Register Handler
@app.route("/register", methods=["POST"])
def register():
    try:
        response = requests.post(
            f"{RAILS_API_BASE}/auth/register",
            json={
                "user": {
                    "email": request.form["email"],
                    "password": request.form["password"],
                    "password_confirmation": request.form["password_confirmation"]
                }
            }
        )
        
        if response.status_code == 201:
            data = response.json()
            session['jwt_token'] = data['token']
            session['user_email'] = data['user']['email']
            session['user_role'] = data['user']['role']
            flash(f"Welcome, {data['user']['email']}! Registration successful.", "success")
            return redirect(url_for("albums_index"))
        else:
            try:
                errors = response.json().get('errors', [f'Registration failed: {response.status_code}'])
            except:
                errors = [f'Registration failed: {response.status_code} - {response.text[:200]}']
            
            for error in errors:
                flash(error, "danger")
            return redirect(url_for("register_page"))
    except Exception as e:
        flash(f"Registration error: {str(e)}", "danger")
        return redirect(url_for("register_page"))

# Login Page
@app.route("/login", methods=["GET"])
def login_page():
    if 'jwt_token' in session:
        return redirect(url_for("albums_index"))
    return render_template("login.html")

# Login Handler
@app.route("/login", methods=["POST"])
def login():
    try:
        response = requests.post(
            f"{RAILS_API_BASE}/auth/login",
            json={
                "email": request.form["email"],
                "password": request.form["password"]
            },
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            session['jwt_token'] = data['token']
            session['user_email'] = data['user']['email']
            session['user_role'] = data['user']['role']
            flash(f"Welcome back, {data['user']['email']}!", "success")
            return redirect(url_for("albums_index"))
        else:
            error_msg = f"Login failed: HTTP {response.status_code}"
            try:
                error_data = response.json()
                error_msg += f" - {error_data.get('error', error_data)}"
            except:
                error_msg += f" - {response.text[:200]}"
            
            flash(error_msg, "danger")
            return redirect(url_for("login_page"))
    except Exception as e:
        flash(f"Login error: {str(e)}", "danger")
        return redirect(url_for("login_page"))

# Logout
@app.route("/logout", methods=["POST"])
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for("login_page"))

if __name__ == "__main__":
    app.run(debug=True)