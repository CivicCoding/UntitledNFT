import {useState} from "react";
import React from "react";
import {ethers} from "ethers";

const NavBar = ({accounts , setAccounts}) => {
    console.log(accounts[0])
    const isConnected = Boolean(accounts[0]);

    async function connWallet() {
        if(window.ethereum){
            const accounts = await window.ethereum.request({
                method:"eth_requestAccounts",
            });
            setAccounts(accounts);
        }
    }

    return(
        <div className="navBar">
            <div id="logo" style={{fontSize: 26}}>UntitledNFT</div>
            <div id="nav">
                <div className="ul">
                    { isConnected ? (
                        <div>
                            Address:{accounts[0]}
                        </div>
                    ) : (
                        <div className="btn-click" id="conn-wallet" onClick={connWallet}>连接钱包</div>
                    )}
                    <div className="btn-click" id="gallery">画廊</div>
                    <div className="btn-click" id="shop">商店</div>
                    <div className="btn-click" id="aboutUs">关于我们</div>
                    <div className="btn-click" id="language">语言</div>
                </div>
            </div>
        </div>
    )
}

export default NavBar;