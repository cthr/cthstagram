<script>
	import Tailwindcss from './Tailwindcss.svelte';

	import { ethStore, web3, selectedAccount, connected } from 'svelte-web3';
	import { onMount } from 'svelte';

	const contractAddress = "0x11C6E6974ebC5f488EC19f2476E4c215dE9Da7Ca";
	const contractABI = [{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"uint32","name":"size","type":"uint32"}],"name":"create","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"uint32","name":"index","type":"uint32"},{"internalType":"string","name":"data","type":"string"}],"name":"uploadChunk","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"uint32","name":"index","type":"uint32"}],"name":"getImageChunk","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageChunks","outputs":[{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getImageIDsByAddress","outputs":[{"internalType":"uint256[]","name":"","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageUploader","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"images","outputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"uploader","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"uploadID","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"users","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];

	onMount(async () => {
		let base64String = await getBase64Image(document.getElementById("uploadedImg"));
		//let base64 = baselet image = (await getImage(2));64String.match(/.{1,8192}/g);
		console.log(base64String);
	});

	const enableBrowser = async () => {
		if($selectedAccount) return;

		await ethStore.setBrowserProvider();
		if($web3.eth && await $web3.eth.net.getId() !== 777) {
            console.log("Wrong Network");
        }

		$web3.eth.subscribe('newBlockHeaders', async function(error, result) {
			console.log("New Block");
		});

		console.log(await getUploadID());
		let numUploads = await getUploadID();
		for(let i = 0; i < numUploads; i++) {
			let imgChunks = await getImage(i);
			let data = imgChunks.join("");

			if(isImage(data)) {
				var imageEle = new Image();
				imageEle.src = 'data:image/jpg;base64,' + data;
				document.body.appendChild(imageEle);
			}
		}

		let base64String = await getBase64Image(document.getElementById("uploadedImg"));
		console.log(base64String);

		console.log(await getImageIDsByAddress($selectedAccount));
	}

	const batchTransactions = async (name = "vitalik.jpg") => {
		let base64String = await getBase64Image(document.getElementById("uploadedImg"));
		let base64 = await base64String.match(/.{1,9216}/g);
		console.log(base64[0]);

		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });

		return new Promise((resolve, reject) => {
			contract.methods.create(name, base64.length).send({
				gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
				from: $selectedAccount,
				to: contractAddress,
				value: $web3.utils.toHex($web3.utils.toWei('10', 'finney'))
			}).on('confirmation', async (confirmationNumber) => {
				if(confirmationNumber === 0) {
					// create confirmed, now upload the chunks
					let imgArray = await getImageIDsByAddress($selectedAccount);
					let imageID = imgArray.slice(-1)[0];
					for(let i = 0; i < base64.length; i++) {
						contract.methods.uploadChunk(imageID, i, base64[i]).send({
							gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
							from: $selectedAccount,
							to: contractAddress
						});

						await sleep(350);
					}
				}
			}).on('error', (error) => {
				console.log("The transaction failed!");
			});
		});
	}

	const getImage = async(id) => {
		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });
		return contract.methods.getImageChunks(id).call().then(function(res) {
			return res;
		});
	}

	const getImageChunk = async(id, index) => {
		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });
		return contract.methods.getImageChunk(id, index).call().then(function(res) {
			return res;
		}); 
	}

	const getImageIDsByAddress = async(account) => {
		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });
		return contract.methods.getImageIDsByAddress(account).call().then(function(res) {
			return res;
		});
	}

	const getUploadID = async() => {
		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });
		return contract.methods.uploadID().call().then(function(res) {
			return res;
		});
	}

	function getBase64Image(img) {
		var canvas = document.createElement("canvas");
		canvas.width = img.width;
		canvas.height = img.height;
		var ctx = canvas.getContext("2d");
		ctx.drawImage(img, 0, 0);
		var dataURL = canvas.toDataURL("image/jpg");
		return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
	}

	function isImage(data) {
		let knownTypes = {
			'/': 'data:image/jpg;base64,',
			'i': 'data:image/png;base64,',
		}
		
		let image = new Image();
		
		if(!knownTypes[data[0]]) {
			console.log("encoded image didn't match known types");
			return false;
		} else {
			image.src = knownTypes[0] + data;
			image.onload = function() {
				if(image.height === 0 || image.width === 0){
					console.log('encoded image missing width or height');
					return false;
				}
			}

			return true;
		}
	}

	window.addEventListener('load', function() {
		document.querySelector('input[type="file"]').addEventListener('change', function() {
			if (this.files && this.files[0]) {
				var img = document.querySelector('img');
				img.onload = () => {
					URL.revokeObjectURL(img.src);
				}

				img.src = URL.createObjectURL(this.files[0]);
			}
		});
	});

	function sleep(ms) {
		return new Promise(resolve => setTimeout(resolve, ms));
	}
</script>

<Tailwindcss />

<style>
</style>

<strong style="color: red;">upload only jpg or png</strong>

<p>
	this is extremely experimental. what you're about to do is upload an <br />
	image to the cheapEth blockchain. the image you select is broken up into chunks <br />
	and then pushed in individual transactions, this is to avoid the block gas limit (8,000,000) <br />
	each transaction will contain roughly 10kb (5994383 gas) and use up 75% of the block space <br />
</p>

<button on:click={enableBrowser}>connect</button>
<button on:click={batchTransactions}>upload</button>

<br />

<strong>image to upload</strong>
<br><input type='file' />
<br><img crossorigin="anonymous" id="uploadedImg" src="#" alt="">

<!--
<img crossorigin="anonymous" id="uploadedImg" src="https://news.bitcoin.com/wp-content/uploads/2020/05/h777s77dh.jpg" alt="">
-->

<strong>images from blockchain</strong>