window.addEventListener('load', () => {
    let form = document.getElementById('form');
    let chatroom_name = document.getElementById('chatroom_name');
    let chatrooms = document.getElementById('chatrooms');


    let xhr_first_load = new XMLHttpRequest();


    xhr_first_load.onreadystatechange = function () {
        if (xhr_first_load.readyState === 4) {
            if (xhr_first_load.status === 200) {
                let json_received = JSON.parse(xhr_first_load.responseText);
                for (value of json_received["chat_rooms"]) {
                    let li = document.createElement('li');
                    let link_chatroom = document.createElement('a');
                    let text = document.createTextNode(value["room_name"]);
                    link_chatroom.href = location.origin + '/chat/' + value["room_url"];
                    link_chatroom.appendChild(text);
                    li.appendChild(link_chatroom);
                    li.classList.add("list-group-item")
                    chatrooms.insertBefore(li, chatrooms.firstChild);
                }
            } else {
                console.log('error.')
            }
        } else {
            console.log('loading.')
        }
    };

    xhr_first_load.open('post', '/list_chatrooms', true);
    xhr_first_load.setRequestHeader('content-type', 'application/x-www-form-urlencoded;charset=UTF-8');
    xhr_first_load.send(null);
    console.log(chatroom_name.value)



    form.addEventListener('submit', e => {
        console.log('submit.');
        let rooms = document.getElementById('rooms');
        // XMLHttpRequestオブジェクト生成
        let xhr = new XMLHttpRequest();


        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    let json_received = JSON.parse(xhr.responseText);
                    let li = document.createElement('li');
                    let link_chatroom = document.createElement('a');
                    let text = document.createTextNode(json_received["chat_room"][0].room_name);
                    link_chatroom.href = location.origin + '/chat/' + json_received["chat_room"][0].room_url;
                    link_chatroom.appendChild(text);
                    li.appendChild(link_chatroom);
                    li.classList.add("list-group-item")
                    chatrooms.insertBefore(li, chatrooms.firstChild);
                } else {
                    console.log('error.')
                }
            } else {
                console.log('loading.')
            }
        };

        xhr.open('post', '/create_chatroom', true);
        xhr.setRequestHeader('content-type', 'application/x-www-form-urlencoded;charset=UTF-8');
        xhr.send('name=' + encodeURIComponent(chatroom_name.value));
        console.log(chatroom_name.value)


        e.preventDefault();
    });
});
