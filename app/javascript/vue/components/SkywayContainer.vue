<template>
  <div class="container">
    <h1 class="heading">
      Room example
    </h1>
    <p class="note">
      Change Room mode (before join in a room):
      <a href="#">mesh</a> / <a href="#sfu">sfu</a>
    </p>
    <div class="room">
      <div>
        <video id="js-local-stream" />
        <button id="js-join-trigger">
          Join
        </button>
        <button id="js-leave-trigger">
          Leave
        </button>
      </div>

      <div id="js-remote-streams" class="remote-streams" />

      <div>
        <pre class="messages">
          <template v-for="message in messages">
            <span v-text="message" />
          </template>
        </pre>
        <input v-model="localText">
        <button @click.prevent="handleSendMessage">
          Send
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue';
import 'skyway-js';

const peer = new Peer({key: process.env.SKYWAY_KEY, debug: 3});

export default {
  components: {
  },
  props: {
  },
  data() {
    return {
      messages: [],
      streams: [],
      localText: '',
    };
  },
  computed: {
  },
  created() {
  },
  async mounted() {
    const roomId = `document_${1}`; // 仮決め

    const localVideo = document.getElementById('js-local-stream');
    const joinTrigger = document.getElementById('js-join-trigger');
    const leaveTrigger = document.getElementById('js-leave-trigger');
    const remoteVideos = document.getElementById('js-remote-streams');
    const localText = document.getElementById('js-local-text');
    const sendTrigger = document.getElementById('js-send-trigger');

    this.localStream = await navigator.mediaDevices
      .getUserMedia({
        audio: true,
        video: true,
      })
      .catch(console.error);

    // Render local stream
    localVideo.muted = true;
    localVideo.srcObject = this.localStream;
    localVideo.playsInline = true;
    await localVideo.play().catch(console.error);

    // Register join handler
    joinTrigger.addEventListener('click', () => {
    // Note that you need to ensure the peer has connected to signaling server
    // before using methods of peer instance.
      if (!peer.open) {
        return;
      }

      this.room = peer.joinRoom(roomId, {
        mode: 'sfu',
        stream: this.localStream,
      });

      this.room.once('open', () => {
        this.messages.push('=== You joined ===');
      });
      this.room.on('peerJoin', peerId => {
        this.messages.push(`=== ${peerId} joined ===`);
      });

      // Render remote stream for new peer join in the room
      this.room.on('stream', async stream => {
        const newVideo = document.createElement('video');
        newVideo.srcObject = stream;
        newVideo.playsInline = true;
        // mark peerId to find it later at peerLeave event
        newVideo.setAttribute('data-peer-id', stream.peerId);
        remoteVideos.append(newVideo);
        await newVideo.play().catch(console.error);
      });

      this.room.on('data', ({ data, src }) => {
      // Show a message sent to the room and who sent
        messages.textContent += `${src}: ${data}\n`;
      });

      // for closing room members
      this.room.on('peerLeave', peerId => {
        const remoteVideo = remoteVideos.querySelector(
          `[data-peer-id=${peerId}]`
        );
        remoteVideo.srcObject.getTracks().forEach(track => track.stop());
        remoteVideo.srcObject = null;
        remoteVideo.remove();

        this.messages.push(`=== ${peerId} left ===`);
      });

      // for closing myself
      this.room.once('close', () => {
        this.messages.push('== You left ===');
        Array.from(remoteVideos.children).forEach(remoteVideo => {
          remoteVideo.srcObject.getTracks().forEach(track => track.stop());
          remoteVideo.srcObject = null;
          remoteVideo.remove();
        });
      });

      leaveTrigger.addEventListener('click', () => {
        if (this.room) {
          console.log('click leave');
          this.room.close();
          this.room = null;
        }
      });
    });

    peer.on('error', console.error);
  },
  methods: {
    handleSendMessage() {
      this.room.send(this.localText);
      this.messages.push(`${peer.id}: ${this.localText}`);
      this.localText = '';
    }
  },
};
</script>
