import {Socket} from "phoenix"

let channel_token = window.document.querySelector("meta[name='channel_token']").content
let socket = new Socket("/socket", {params: {channel_token: channel_token}})
socket.connect()

export default socket
