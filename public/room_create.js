window.addEventListener('load', () => {
    let form = document.getElementById('form');
    let chatroom_name = document.getElementById('chatroom_name');
    let chatrooms = document.getElementById('chatrooms');

    form.addEventListener('submit', e => {
        console.log('submit.');
        let rooms = document.getElementById('rooms');
        // XMLHttpRequestオブジェクト生成
        let xhr = new XMLHttpRequest();


        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    let li = document.createElement('li');
                    let link_chatroom = document.createElement('a');
                    let text = document.createTextNode(xhr.responseText);
                    link_chatroom.href = location.origin + '/chat/' + xhr.responseText;
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
