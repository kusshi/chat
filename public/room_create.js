window.addEventListener('load', () => {
    let form = document.getElementById('form');
    let chatroom_name = document.getElementById('chatroom_name');

    form.addEventListener('submit', e => {
        console.log('submit.');
        let rooms = document.getElementById('rooms');
        // XMLHttpRequestオブジェクト生成
        let xhr = new XMLHttpRequest();


        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    rooms.textContent = xhr.responseText;
                } else {
                    rooms.textContent = 'error.'
                }
            } else {
                rooms.textContent = 'loading'
            }
        };

        xhr.open('post', '/create_chatroom', true);
        xhr.setRequestHeader('content-type', 'application/x-www-form-urlencoded;charset=UTF-8');
        xhr.send('name=' + encodeURIComponent(chatroom_name.value));
        console.log(chatroom_name.value)


        e.preventDefault();
    });
});
