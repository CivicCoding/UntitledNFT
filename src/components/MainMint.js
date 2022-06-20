import {useState} from "react";
import {ethers , BigNumber} from "ethers";
import UntitledNFT from "../UntitledNFT.json";

const UntitledNFTContractAddress = "0xa1d5e7b17A0B06e3eCB155020f7d3D26C63aB8CE"

const MainMint = ({ accounts, setAccount}) => {
    const [mintAmount, setMintAmount ] = useState(1);
    const isConnected = Boolean(accounts[0]);

    async function handleMint(){
        if(window.ethereum){
            //TODO: 添加判断publicsaleison，添加判断contract owner
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(UntitledNFTContractAddress,UntitledNFT.abi,signer);
            try{
                const response = await contract.publicSaleMint(BigNumber.from(mintAmount));
                console.log("response:",response);
            }catch (err){
                console.log("Error",err);
            }
        }
    }
    
    const handleDecrement = () => {
        if(mintAmount <= 1){
            return;
        }
        setMintAmount(mintAmount - 1);
    };

    const handleIncrement = () => {
        if(mintAmount >= 10){
            return;
        }
        setMintAmount(mintAmount + 1);
    };

    return(
        <div className="MainMint">
            {isConnected? (
                <div>
                    <div>
                        <button id="in-decrement" onClick={handleDecrement}>-</button>
                        <input type="number" value={mintAmount} />
                        <button id="in-decrement" onClick={handleIncrement}>+</button>
                    </div>
                        <button id="mint" onClick={handleMint}>Mint</button>
                </div>
            ):(
                <div>
                    <p>
                        have not connect wallet yet!!!
                    </p>
                </div>
            )}
        </div>
    );
}

export default MainMint;