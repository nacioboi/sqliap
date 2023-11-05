const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const app = express();
const { exec } = require('child_process');



app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));



const db = mysql.createConnection({
	host: 'localhost',
	user: 'root',
	password: 'passwd',
	database: 'mydb',
});



db.connect((err) => {
	if (err) throw err;
	console.log('Connected to MySQL 🎉');
});



app.post('/login', (req, res) => {
	const { username, password } = req.body;

	// this is intentionally vulnerable to SQL injection,
	// 	we want to test our hacking skills...
	const sql = `SELECT * FROM users WHERE username = '${username}' AND passwd = '${password}'`;

	// making hacking even more easy by returning the output of the query to the client.
	// this would never happen in a real application, but its fun. :D
	//
	// we are even going one step further, when we run the query, we're going to always use the correct database to make the hackers
	// life easier. again, this would never happen in a real application, but its fun. :D
	exec(`mysql -u root --password=passwd -e "USE mydb; ${sql}"`, (err, stdout, stderr) => {
		if (err && err.message && err.message.includes("Command failed")) {
			console.log(err)
		}
		else {
			if (err) throw err
		}
		out = stdout + stderr

		db.query(sql, [], (_err, result) => {
			if (_err) throw _err;
			if (result.length > 0) {
				res.json({ success: true, diagnostic: out });
			} else {
				res.json({ success: false, diagnostic: out });
			}
		});
	});
});



app.get('/', (req, res) => {
	res.sendFile(__dirname + '/index.html');
});



app.get('/index.css', (req, res) => {
	res.sendFile(__dirname + '/index.css');
});



app.get('/index.js', (req, res) => {
	res.sendFile(__dirname + '/index.js');
});



app.listen(3000, () => {
	console.log('Server started on http://localhost:3000 😎');
});
