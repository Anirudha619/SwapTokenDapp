import logo from './logo.svg';
import { useState } from "react";
import { ethers } from "ethers";
import './App.css';
import SwapToken from "./artifacts/contracts/SwapContract.sol/SwapContract.json"

const requestAccount = async () => {
  if (typeof window.ethereum !== "undefined") {
    const provider = window.ethereum;
    await provider.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: '0x3' }], // chainId must be in hexadecimal numbers
    });
    await provider.request({
      method: "eth_requestAccounts",
      params: [{ chainId: '0x3' }],
    });
    
  }
  
};
function App() {
  const [tokenIn, setTokenIn] = useState("");
  const [tokenInAmount, setTokenInAmount] = useState("");
  const [tokenOut, setTokenOut] = useState("");
  const SwapContractAddress = "0x5d1e9Ed3c0Da654798a0A31dd1ed2D751343Fd12";

  async function swapExactInputSingle(tokenIn, tokenOut, amountIn){
    if (typeof window.ethereum !== "undefined") {
      await requestAccount();
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      console.log({ provider });
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        SwapContractAddress,
        SwapToken.abi,
        signer
      );
      const transaction = await contract.swapExactInputSingle(tokenIn, tokenOut, amountIn);
      await transaction.wait();
    }
    
  }

  async function swap(){
    await requestAccount()
    let amountIn = ethers.utils.parseEther(tokenInAmount.toString()).toString();
    console.log(amountIn)
    console.log(tokenIn)
    console.log(tokenOut)
    await swapExactInputSingle(tokenIn, tokenOut, amountIn);
  }

  return (
    <div className="App">
      <h1>Swap Token</h1>
      <main className="container">
        <label for="InputToken">Input Token Address</label>
        <input type="text" id="InputToken" name="InputToken" placeholder="Input Token Address" onChange={(e)=>setTokenIn(e.target.value)}></input>
        <label for="InputTokenAmount">Input Token Amount</label>
        <input type="text" id="InputTokenAmount" name="InputTokenAmount" placeholder="Input Token Amount" onChange={(e)=>setTokenInAmount(e.target.value)}></input>
        <label for="OutputToken">Output Token Address</label>
        <input type="text" id="OutputToken" name="OutputToken" placeholder="Output Token Address" onChange={(e)=>setTokenOut(e.target.value)}></input><br/>
        <button className='glow-button' onClick={()=>swap()}>Swap</button>
      </main>
    </div>
  );
}

export default App;
