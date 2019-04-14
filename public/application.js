window.addEventListener('load', () => {
  let msgbox = document.getElementById('msgs');
  let form = document.getElementById('form');
  let sendMsg = document.getElementById('send-msg');
  let ws = new WebSocket('ws://' + window.location.host + '/websocket');
  let login_user_name = ""

  ws.onopen = () => console.log('connection opened');
  ws.onclose = () => console.log('connection closed');
  ws.onmessage = m => {
    json_received = JSON.parse(m.data);
    if (json_received.hasOwnProperty('login_user_name')) {
      login_user_name = json_received.login_user_name;
      // console.log("")
    } else {
      let li = document.createElement('li');
      li.classList.add("list-group-item")
      li.textContent = "[" + json_received.user_name + "]  " + json_received.text;
      if (json_received.user_name == login_user_name) {
        li.style.backgroundColor = '#d3d3d3'
      } else {
        li.style.backgroundColor = '#f0e68c'
      }
      msgbox.insertBefore(li, msgbox.firstChild);
      console.log(JSON.stringify(json_received))
      console.log(json_received.text)
    }

  }

  sendMsg.addEventListener('click', () => sendMsg.value = '');

  form.addEventListener('submit', e => {
    let msg_obj = {};
    msg_obj.text = sendMsg.value;
    // msg_obj.usr_id = "userID";
    msg_json = JSON.stringify(msg_obj);
    // ws.send(sendMsg.value);
    ws.send(msg_json);
    sendMsg.value = '';
    e.preventDefault();
  });
});
