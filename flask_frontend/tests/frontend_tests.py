import unittest
import requests

BASE_URL = "https://albumtrackerca.onrender.com/api/albums"

class FlaskFrontendTestCase(unittest.TestCase):
    def setUp(self):
        self.album_data = {
            "title": "Test Album",
            "artist": "Test Artist",
            "release_year": 2025,
            "genre": "Pop",
            "rating": 4,
            "availability": True
        }

        response = requests.post(BASE_URL, json=self.album_data)
        self.assertIn(response.status_code, [200, 201], f"Failed to create album: {response.text}")
        self.album = response.json()
        self.album_id = self.album["id"]

    def tearDown(self):
        requests.delete(f"{BASE_URL}/{self.album_id}")

    def test_album_index(self):
        response = requests.get(BASE_URL)
        self.assertEqual(response.status_code, 200)
        albums = response.json()
        self.assertIsInstance(albums, list)
        self.assertTrue(any(a["id"] == self.album_id for a in albums))

    def test_album_show(self):
        response = requests.get(f"{BASE_URL}/{self.album_id}")
        self.assertEqual(response.status_code, 200)
        album = response.json()
        self.assertEqual(album["title"], self.album_data["title"])
        self.assertEqual(album["artist"], self.album_data["artist"])

    def test_album_update(self):
        update_data = {"title": "Updated Album"}
        response = requests.patch(f"{BASE_URL}/{self.album_id}", json=update_data)
        self.assertEqual(response.status_code, 200)
        album = response.json()
        self.assertEqual(album["title"], "Updated Album")

    def test_album_delete(self):
        response = requests.delete(f"{BASE_URL}/{self.album_id}")
        self.assertEqual(response.status_code, 204)
        response = requests.get(f"{BASE_URL}/{self.album_id}")
        self.assertEqual(response.status_code, 404)

if __name__ == "__main__":
    unittest.main()
