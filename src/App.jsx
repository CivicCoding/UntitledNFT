
import './App.css';
import background from "./img/background.jpeg"
import weibo from "./img/weibo.png"
import discord from "./img/discord.png"
import twitter from "./img/twitter.png"

import {ethers, utils} from "ethers";

const DEBUG = true;

function App() {
    async function connWallet() {
        // A Web3Provider wraps a standard Web3 provider, which is
        // what MetaMask injects as window.ethereum into each page
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        //const provider = new ethers.providers.StaticJsonRpcProvider(URL,"ropsten");
        if(DEBUG) console.log(provider);
        //返回 provider 连接的网络
        if(DEBUG) console.log(await provider.getNetwork());
        //当前区块数量
        const currentBlockNumber = await provider.getBlockNumber();
        if(DEBUG) console.log(`currentBlockNumber:${currentBlockNumber}`);
        //获取gas price
        const gasPrice = (await provider.getGasPrice());
        //gasPrice 以Gwei显示
        if(DEBUG) console.log(utils.formatUnits(gasPrice,"gwei"));

        // const balance = await provider.getBalance("MATIC")
        // console.log(balance);


        // MetaMask requires requesting permission to connect users accounts
        await provider.send("eth_requestAccounts", []);

        // The MetaMask plugin also allows signing transactions to
        // send ether and pay to change state within the blockchain.
        // For this, you need the account signer...
        const signer = provider.getSigner();
        console.log(signer);

    }

    return (
    <div className="App">
        <div className="sm-content">
            <div id="sm-background">
                <div className="sm-icon">
                    <img id="weibo" src={weibo}/>
                </div>
                <div className="sm-icon">
                    <img id="twitter" src={twitter}/>
                </div>
                <div className="sm-icon">
                    <img id="discord" src={discord}/>
                </div>
            </div>
        </div>
        <div className="navBar">
            <div id="logo" style={{fontSize: 26}}>UntitledNFT</div>
            <div id="nav">
                <div className="ul">
                    <div className="btn-click" id="conn-wallet" onClick={connWallet}>连接钱包</div>
                    <div className="btn-click" id="gallery">画廊</div>
                    <div className="btn-click" id="shop">商店</div>
                    <div className="btn-click" id="aboutUs">关于我们</div>
                    <div className="btn-click" id="language">语言</div>
                </div>
            </div>
        </div>
        <div className="content">
            <div id="textBackground">
                <div id="text">keep cool</div>
                <img id="showImg" src={background} alt="background"/>
            </div>
        </div>
    </div>
  );
}

export default App;
