import React, {useState} from "react";
import {BigNumber, ethers} from "ethers";
import UntitledNFt from "../UntitledNFT.json"
const UntitledNFTAddress = "0xa1d5e7b17A0B06e3eCB155020f7d3D26C63aB8CE";
const DEBUG = false;
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();
const contract = new ethers.Contract(UntitledNFTAddress,UntitledNFt.abi,signer);
const publicPriceWei = ethers.utils.parseEther("0.1");
const SaleKey = BigNumber.from("31415926");
let publicSaleStartTime;

const Manage = ({accounts}) => {
    const managerAddress = useState("0x0b8615e756c5a839f035cb1be0d6e120caea5e72");
    const isManager = accounts[0] === managerAddress[0];
    if(DEBUG) console.log("isManager:",isManager);
    if(DEBUG) console.log("managerAddress:",managerAddress[0]);

    async function setPublicSaleTime(time){
        publicSaleStartTime = Math.round(new Date(time)/1000);
        try{
            const response = await contract.setAuctionSaleStartTime(publicSaleStartTime);
            console.log("response:",response)
        }catch(err){
            console.log("Error:",err)
        }
    }

    async function setPublicSaleKey(){
        try{
            const response = await contract.setPublicSaleKey(SaleKey);
            console.log("response:",response);
        }catch (err) {
            console.log("Error:",err);
        }
    }

    async function isPublicSaleOn() {
        try{
             return  await contract.isPublicSaleOn(publicPriceWei,SaleKey,publicSaleStartTime);
        }catch (err){
            console.log("Error",err);
        }
    }

    const handlePublicSaleTimeAndKey = () => {
        let time = document.getElementById("time").value;
        setPublicSaleTime(time)
            .then(r => console.log(r))
            .catch(err => console.log(err));
        setPublicSaleKey()
            .then(r => console.log(r))
            .catch(err => console.log("Error:",err));
    }

    return (
        <div className="Manage">
            {isManager ? (
                <div>
                    <div id="publicSaleTime">
                        <div id="setTime">set public sale time:</div>
                        <input id="time" name="time" />
                        <button className="btn-click" onClick={handlePublicSaleTimeAndKey}>确定</button>
                    </div>
                </div>

            ):(
                <div>NOT MANAGER</div>
            ) }
        </div>

    )
}

export default Manage;