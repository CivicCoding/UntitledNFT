
import './App.css';
import background from "./img/background.jpeg"
import weibo from "./img/weibo.png"
import discord from "./img/discord.png"
import twitter from "./img/twitter.png"
import buddha from "./img/Buddha.JPG"

import {ethers, utils} from "ethers";
import MainMint from "./components/MainMint";
import NavBar from "./components/NavBar";
import {useState} from "react";
import Manage from "./components/Manage";

const DEBUG = true;

function App() {
    const [accounts, setAccounts] = useState([])

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
        <NavBar accounts={accounts} setAccounts={setAccounts}></NavBar>
        <div className="content">
            <div id="textBackground">
                <div id="text">
                    <Manage accounts={accounts}></Manage>
                    <MainMint accounts={accounts} setAccount={setAccounts}></MainMint>
                </div>
                <img id="showImg" src={buddha} alt="buddha"/>
            </div>
        </div>
    </div>
  );
}

export default App;
