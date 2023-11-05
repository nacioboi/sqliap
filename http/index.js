function submitted() {
	console.log(`[submitted]: called...`);
	event.preventDefault();

	const username = document.getElementById("username-field").value;
	const password = document.getElementById("password-field").value;
	console.log(`[submitted]: username:[${username}], password:[${password}]`);

	output_area = document.getElementById("output-area");
	console.log(`[submitted]: output_area:[${output_area}]`)

	console.log(`[submitted]: calling ajax...`);
	$.ajax({
		type: "POST",
		url: "http://localhost:3000/login",
		data: {username, password},
		success: function (response) {
			const bad = "mysql: [Warning] Using a password on the command line interface can be insecure.\n"
			const diag = response.diagnostic.replace(bad, "");
			console.log(`[submitted]: {\nresponse.success:[${response.success}]\nresponse.diagnostic:[\n${diag}\n]\n}`);
			output_area.innerHTML = `response.success:[${response.success}]\nresponse.diagnostic:[\n${diag}}\n]`;
		}
	});
}

function showSettings() {
	console.log(`[showSettings]: called...`);
	var form = document.querySelector('.settings-form');
	console.log(`[showSettings]: form:[${form}]`);
	form.classList.toggle('hidden');
	console.log(`[showSettings]: form.classList.toggled:[${form.classList.toggled}]`);
}

function saveCookie(name, value) {
	console.log(`[saveCookie] called...`);
	document.cookie = `${name}=` + encodeURIComponent(value) + "; path=/";
	console.log(`[saveCookie] new cookie, name:[${name}], value:[${value}]`);
	console.log(`[saveCookie] to confirm, document.cookie:[\n${document.cookie}\n]`);
}

function loadSettings() {
	console.log(`[loadSettings] called...`);
	var username = getCookie('username');
	var password = getCookie('password');
	console.log(`[loadSettings] username:[${username}], password:[${password}]`);

	var syncEnabled = getCookie('syncEnabled');
	var autorunEnabled = getCookie('autorunEnabled');
	var outputAreaEnabled = getCookie('outputAreaEnabled');
	var terminalEnabled = getCookie('terminalEnabled');
	console.log(`[loadSettings] syncEnabled:[${syncEnabled}], autorunEnabled:[${autorunEnabled}]`);
	console.log(`[loadSettings] terminalEnabled:[${terminalEnabled}]`);

	if (username) {
		document.getElementById("username-field").value = username;
		console.log(`[loadSettings] username-field.value:[${document.getElementById("username-field").value}]`);
	}

	if (password) {
		document.getElementById("password-field").value = password;
		console.log(`[loadSettings] password-field.value:[${document.getElementById("password-field").value}]`);
	}

	if (syncEnabled === 'true') {
		document.getElementById('sync-enabled').checked = true;
		console.log(`[loadSettings] sync-enabled.checked:[${document.getElementById('sync-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleSync(true)...`)
		toggleSync(true);
	}
	if (syncEnabled === 'false') {
		document.getElementById('sync-enabled').checked = false;
		console.log(`[loadSettings] sync-enabled.checked:[${document.getElementById('sync-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleSync(false)...`)
		toggleSync(false);
	}

	if (autorunEnabled === 'true') {
		document.getElementById('autorun-enabled').checked = true;
		console.log(`[loadSettings] autorun-enabled.checked:[${document.getElementById('autorun-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleAutorun(true)...`)
		toggleAutorun(true);
		autorunSubmission(); // Run once to initialize.

	}
	if (autorunEnabled === 'false') {
		document.getElementById('autorun-enabled').checked = false;
		console.log(`[loadSettings] autorun-enabled.checked:[${document.getElementById('autorun-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleAutorun(false)...`)
		toggleAutorun(false);
	}

	if (outputAreaEnabled === 'true') {
		document.getElementById('output-area-enabled').checked = true;
		console.log(`[loadSettings] output-area-enabled.checked:[${document.getElementById('output-area-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleOutputArea(true)...`)
		toggleOutputArea(true);
	} else {
		document.getElementById('output-area-enabled').checked = false;
		console.log(`[loadSettings] output-area-enabled.checked:[${document.getElementById('output-area-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleOutputArea(false)...`)
		toggleOutputArea(false);
	}


	if (terminalEnabled === 'true') {
		document.getElementById('terminal-enabled').checked = true;
		console.log(`[loadSettings] terminal-enabled.checked:[${document.getElementById('terminal-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleTerminal(true)...`)
		toggleTerminal(true);
	}
	if (terminalEnabled === 'false') {
		document.getElementById('terminal-enabled').checked = false;
		console.log(`[loadSettings] terminal-enabled.checked:[${document.getElementById('terminal-enabled').checked}]`);
		console.log(`[loadSettings] calling toggleTerminal(false)...`)
		toggleTerminal(false);
	}
}

function getCookie(name) {
	console.log(`[getCookie] called...`);
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) {
			console.log(`[getCookie] returning c.substring(nameEQ.length, c.length):[${c.substring(nameEQ.length, c.length)}]`);
			return decodeURIComponent(c.substring(nameEQ.length, c.length));
		}
	}
	return null;
}

function toggleSync(isEnabled) {
	console.log(`[toggleSync] called...`);
	console.log(`[toggleSync] saving cookie, name:[syncEnabled], value:[${isEnabled}]`);
	saveCookie('syncEnabled', isEnabled);
	if (isEnabled) {
		$('#username-field, #password-field').on('input', updateSyncedCredentials);
		console.log(`[toggleSync] enabled:[updateSyncedCredentials]`);
	} else {
		$('#username-field, #password-field').off('input', updateSyncedCredentials);
		console.log(`[toggleSync] disabled:[updateSyncedCredentials]`);
	}
}

function updateSyncedCredentials() {
	console.log(`[updateSyncedCredentials] called...`);
	saveCookie('username', $('#username-field').val());
	saveCookie('password', $('#password-field').val());
	console.log(`[updateSyncedCredentials] username: [${$('input[name=username-field]').val()}]`);
	console.log(`[updateSyncedCredentials] password: [${$('input[name=password-field]').val()}]`);
}

function toggleAutorun(isEnabled) {
	console.log(`[toggleAutorun] called...`);
	saveCookie('autorunEnabled', isEnabled);
	console.log(`[toggleAutorun] saving cookie, name:[autorunEnabled], value:[${isEnabled}]`);
	if (isEnabled) {
		$('#username-field, #password-field').on('input', autorunSubmission);
		console.log(`[toggleAutorun] enabled:[autorunSubmission]`);
	} else {
		$('#username-field, #password-field').off('input', autorunSubmission);
		console.log(`[toggleAutorun] disabled:[autorunSubmission]`);
	}
}

function autorunSubmission() {
	console.log(`[autorunSubmission] called...`);
	submitted();
}

function toggleOutputArea(isEnabled) {
	console.log(`[toggleOutputArea] called...`);
	const outputArea = document.getElementById('output-area');
	const loginForm = document.querySelector('.login-form');
	saveCookie('outputAreaEnabled', isEnabled);
	console.log(`[toggleOutputArea] outputArea:[${outputArea}], loginForm:[${loginForm}]`);

	if (isEnabled) {
		console.log(`[toggleOutputArea] showing output area...`);
		outputArea.style.display = 'block'; // Show output area
		loginForm.style.flex = 'none'; // Stop the login form from growing
		loginForm.style.width = '300px'; // Set the login form width to a fixed value
	} else {
		console.log(`[toggleOutputArea] hiding output area...`);
		outputArea.style.display = 'none'; // Hide output area
		loginForm.style.flex = ''; // Allow the login form to be flexible (back to default)
		loginForm.style.width = ''; // Allow the login form to have its original width (back to default)
	}
}

function toggleTerminal(isEnabled) {
	console.log(`[toggleTerminal] called...`);
	if (isEnabled) {
		showTerminal();
		console.log(`[toggleTerminal] showing terminal...`);
	} else {
		hideTerminal();
		console.log(`[toggleTerminal] hiding terminal...`)
	}
}

function showTerminal() {
	// Initialize and show the terminal. This will likely involve creating an instance
	// of the terminal library and connecting it to the WebSocket or SSH stream.
	console.log(`[showTerminal] called...`);
}

function hideTerminal() {
	// Hide the terminal and clean up if necessary.
	console.log(`[hideTerminal] called...`);
}

window.onload = function () {
	console.log(`[window.onload] called...`);
	console.log(`[window.onload] calling loadSettings()...`);
	loadSettings();
};
