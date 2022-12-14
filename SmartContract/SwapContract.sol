// SPDX-License-Identifier: unlicence
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";

/// @title SwapContract
/// @author Anirudha Thorat
/// @notice This contract swaps ERC20 tokens.
contract SwapContract {
    ISwapRouter public immutable swapRouter;
    IQuoterV2 public immutable quoterV2;
    using Counters for Counters.Counter;
    Counters.Counter private transcationId;
    uint256 public lastAmountOut;
    uint256 public lastGasEstimate;
    
    constructor(ISwapRouter _swapRouter, IQuoterV2 _quoterV2){
        swapRouter = ISwapRouter(_swapRouter);
        quoterV2 = IQuoterV2(_quoterV2);
    }

    struct Transaction{
        address user;
        address swappedToken;
        address receivedToken;
        uint receivedTokenAmount;
    }

    //store swap data after each swap 
    mapping(uint => Transaction) public transcations;

    // @notice Swaps a fixed amount of InputToken for a maximum possible amount of OutputToken
    // @dev make sure to approve input token for address(this), otherwise it will give STL error 
    // @param _tokenIn : address of input token
    //        _tokenOut : address of output token
    //        _amountIn : amount of input token 
    function swapExactInputSingle(
        address _tokenIn, 
        address _tokenOut, 
        uint _amountIn
    )
        external
        returns (uint amountOut)
    {
        require(_tokenIn != address(0), "tokenIn should not be a zero address");
        require(_tokenOut != address(0), "tokenOut should not be a zero address");
        require(_tokenIn != _tokenOut, "tokenIn should not be equal to tokenOut");
        require(_amountIn > 0, "amountIn should not be a zero address");

        TransferHelper.safeTransferFrom(
            _tokenIn,
            msg.sender,
            address(this),
            _amountIn
        );
        TransferHelper.safeApprove(_tokenIn, address(swapRouter), _amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
        .ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            // pool fee 0.3%
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        amountOut = swapRouter.exactInputSingle(params);

        transcations[transcationId.current()] = Transaction(msg.sender, _tokenIn, _tokenOut, amountOut);
        transcationId.increment();
    }

    function getAmountsOut(
        address _tokenIn, 
        address _tokenOut, 
        uint _amountIn
    )external {
        IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2
        .QuoteExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            amountIn: _amountIn,
            fee: 3000,
            sqrtPriceLimitX96: 0
        });
        (
            uint256 amountOut,
            ,
            ,
            uint256 gasEstimate
        ) = quoterV2.quoteExactInputSingle(params);
        lastAmountOut = amountOut;
        lastGasEstimate = gasEstimate;
    }

}