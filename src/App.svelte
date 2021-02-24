<script>
	import Tailwindcss from './Tailwindcss.svelte';

	import { ethStore, web3, selectedAccount, connected } from 'svelte-web3';
	import { onMount } from 'svelte';

	const contractAddress = "0x1c8cEdeA1C81EbC26f9bb6CAF862C920FAc43aC1";
	const contractABI = [{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"uint32","name":"size","type":"uint32"}],"name":"create","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"uint32","name":"index","type":"uint32"}],"name":"getImageChunk","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageChunks","outputs":[{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageUploader","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"images","outputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"uploader","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"uint32","name":"index","type":"uint32"},{"internalType":"string","name":"data","type":"string"}],"name":"uploadChunk","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"uploadID","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];

	let base64 = [];

	onMount(async () => {
		/*let base64String = await getBase64Image(document.getElementById("uploadedImg"));
		let base64 = base64String.match(/.{1,8192}/g);
		console.log(base64String);*/
	});

	const enableBrowser = async () => {
		await ethStore.setBrowserProvider();
		if($web3.eth && await $web3.eth.net.getId() !== 777) {
            console.log("Wrong Network");
        }

		$web3.eth.subscribe('newBlockHeaders', async function(error, result) {
			console.log("New Block");
		});

		let image = (await getImage(0));
		console.log(image.join(""));

		var imageEle = new Image();
		imageEle.src = 'data:image/png;base64,' + image.join("");
		document.body.appendChild(imageEle);
	}

	const batchTransactions = async (name = "cTH logo") => {
		let base64String = await getBase64Image(document.getElementById("uploadedImg"));
		let base64 = await base64String.match(/.{1,9216}/g);
		console.log(base64[0]);

		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });

		contract.methods.create(name, base64.length).send({
			gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
			gasLimit: $web3.utils.toHex(155000),
			from: $selectedAccount,
			to: contractAddress,
			value: $web3.utils.toHex($web3.utils.toWei('10', 'finney'))
		});

		await sleep(600);

		for(let i = 0; i < base64.length; i++) {
			contract.methods.uploadChunk(0, i, base64[i]).send({
				gasPrice: $web3.utils.toHex($web3.utils.toWei('1', 'gwei')),
				gasLimit: $web3.utils.toHex(5994383),
				from: $selectedAccount,
				to: contractAddress
			});

			await sleep(350);
		}
	}

	const getImage = async(id) => {
		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });
		return contract.methods.getImageChunks(id).call().then(function(res) {
			return res;
		});
	}

	function getBase64Image(img) {
		var canvas = document.createElement("canvas");
		canvas.width = img.width;
		canvas.height = img.height;
		var ctx = canvas.getContext("2d");
		ctx.drawImage(img, 0, 0);
		var dataURL = canvas.toDataURL("image/png");
		return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
	}

	function sleep(ms) {
		return new Promise(resolve => setTimeout(resolve, ms));
	}
</script>

<Tailwindcss />

<style>
</style>

<p>
	this is extremely experimental. what you're about to do is upload an <br />
	image to the cheapEth blockchain. the image you select is broken up into chunks <br />
	and then pushed in individual transactions, this is to avoid the block gas limit (12,000,000) <br />
	which only allows us to push ~10kb at a time.
</p>

<button on:click={enableBrowser}>connect</button>
<button on:click={batchTransactions}>upload</button>

<img crossorigin="anonymous" id="uploadedImg" src="https://cheapeth.org/images/logo.png" alt="">
