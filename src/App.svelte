<script>
	import Tailwindcss from './Tailwindcss.svelte';

	import { ethStore, web3, selectedAccount, connected } from 'svelte-web3';
	import { onMount } from 'svelte';

	const contractAddress = "0xc3E5180a32402583BC73B8669E8d1bB2654B965d";
	const contractABI = [{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"create","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"string","name":"data","type":"string"}],"name":"uploadChunk","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageChunks","outputs":[{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"getImageUploader","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"images","outputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"uploader","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"uploadID","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];

	let base64 = "";

	onMount(async () => {
		base64 = getBase64Image(document.getElementById("imageid"));
		console.log(base64);
	});

	const enableBrowser = async () => {
		await ethStore.setBrowserProvider();
		if($web3.eth && await $web3.eth.net.getId() !== 777) {
            console.log("Wrong Network");
        }

		$web3.eth.subscribe('newBlockHeaders', async function(error, result) {
			console.log("New Block");
		})
	}

	const batchTransactions = async (name) => {
		let contract = new $web3.eth.Contract(contractABI, contractAddress, { from: $selectedAccount });

		/*var batch = $web3.createBatch();
		batch.add(contract.create(arg1, {from: account, gas: 4000000}));
		batch.add(contract.doSomethingElse(arg1, arg2, {from: account, gas: 4000000}));
		batch.add(contract.doSomethingElseEntirely(arg1, arg2, {from: account, gas: 4000000}));
		batch.execute();*/
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
</script>

<Tailwindcss />

<style>
</style>

<button on:click={enableBrowser}>Connect Wallet</button>
<button on:click={batchTransactions}>Send Transaction</button>

<img id="imageid" src="https://cheapeth.org/images/logo.png" alt="">
