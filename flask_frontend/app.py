from flask import Flask, render_template, request, redirect, flash, url_for
import requests

app = Flask(__name__)
app.secret_key = "SECRET_KEY"

RAILS_API = "http://localhost:3000/api/albums"

@app.route("/")
def root():
    return redirect(url_for("albums_index"))

# Index/Home
@app.route("/albums")
def albums_index():
    query = request.args.get("q")
    params = {"q": query} if query else {}
    response = requests.get(RAILS_API, params=params)
    
    albums = response.json() if response.status_code == 200 else []
    
    return render_template("albums/index.html", albums=albums, query=query)

# View Album Details
@app.route("/albums/<int:album_id>")
def albums_show(album_id):
    response = requests.get(f"{RAILS_API}/{album_id}")
    if response.status_code == 200:
        album = response.json()
    else:
        flash(f"Album not found.", "danger")
        return redirect(url_for("albums_index"))
    
    return render_template("albums/show.html", album=album)

# New Album
@app.route("/albums/new")
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
        data = {f"album[{k}]": v for k, v in album_data.items()}
        response = requests.post(RAILS_API, data=data, files=files)
    else:
        response = requests.post(
            RAILS_API,
            json={"album": album_data}
        )

    return redirect(url_for("albums_index"))

# Edit
@app.route("/albums/<int:album_id>/edit")
def albums_edit(album_id):
    response = requests.get(f"{RAILS_API}/{album_id}")
    album = response.json()
    return render_template("albums/edit.html", album=album)

# Update
@app.route("/albums/<int:album_id>/update", methods=["POST"])
def albums_update(album_id):
    album_data = {
        "album": {
            "title": request.form["title"],
            "artist": request.form["artist"],
            "release_year": request.form["release_year"],
            "genre": request.form["genre"],
            "rating": request.form["rating"],
            "availability": "availability" in request.form
        }
    }

    # If an image is uploaded → multipart
    if "cover_image" in request.files and request.files["cover_image"].filename:
        files = {
            "cover_image": request.files["cover_image"]
        }
        response = requests.put(
            f"{RAILS_API}/{album_id}",
            data=album_data,
            files=files
        )
    else:
        # No image → JSON
        response = requests.put(
            f"{RAILS_API}/{album_id}",
            json=album_data
        )

    if response.status_code in [200, 204]:
        flash("Album updated successfully!", "success")
    else:
        flash(f"Failed to update album: {response.text}", "danger")

    return redirect(url_for("albums_show", album_id=album_id))

# Delete
@app.route("/albums/<int:album_id>/delete", methods=["POST"])
def albums_delete(album_id):
    response = requests.delete(f"{RAILS_API}/{album_id}")
    if response.status_code in [200, 204]:
        flash("Album deleted successfully!", "success")
    else:
        flash(f"Failed to delete album: {response.text}", "danger")
    return redirect(url_for("albums_index"))

if __name__ == "__main__":
    app.run(debug=True)
