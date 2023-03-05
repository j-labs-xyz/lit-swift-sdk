//
//  LitActionCode.swift
//  Lit_swift
//
//  Created by leven on 2023/3/5.
//

import Foundation
struct LitActionJSCode {
    static let baseTransactionCode = """
            const fromAddressParam = ethers.utils.computeAddress(publicKey);
            const latestNonce = await LitActions.getLatestNonce({ address: fromAddressParam, chain });
            const txParams = {
              nonce: latestNonce,
              gasPrice: gasPrice,
              gasLimit: gasLimit,
              to: toAddress,
              value: value,
              chainId: chainId,
              data: data,
            };

            LitActions.setResponse({ response: JSON.stringify(txParams) });
            const serializedTx = ethers.utils.serializeTransaction(txParams);
            const rlpEncodedTxn = ethers.utils.arrayify(serializedTx);
            const unsignedTxn =  ethers.utils.arrayify(ethers.utils.keccak256(rlpEncodedTxn));

            const sigShare = await LitActions.signEcdsa({ toSign: unsignedTxn, publicKey, sigName });
           
 """
    
    static func getDailyLimitTransactionCode(maxValue: Double) -> String {
        return """
    const go = async () => {
      const address = ethers.utils.computeAddress(publicKey);
      const apiKeys = ["FRMV3PA3SVXFNGNZWVTJXFJHJB5MU8C54S", "3NUZY7URAX4D7DCT4ZPC1M3CEN37V3JYAF", "3NUZY7URAX4D7DCT4ZPC1M3CEN37V3JYAF"]
      console.log("address:",address)
      const timeout = (ms) =>  {
        return new Promise(resolve => setTimeout(resolve, ms));
      }
      const randomTimeout = async () =>  {
        const delay = Math.random() * 3
        return timeout(delay * 1000);
      }
      const isToday = (timsStamp) => {
        const someDate = new Date(timsStamp)
        const today = new Date()
        return someDate.getUTCDate() == today.getUTCDate() &&
          someDate.getUTCMonth() == today.getUTCMonth() &&
          someDate.getUTCFullYear() == today.getUTCFullYear()
      }
      const urlAppendParams = (url, params) => {
        url = url + "?" + Object.keys(params).map((key) => key + "=" + params[key]).join("&")
        return url
      }
      const getTodayTransactions = async (page, transactions) => {
        const apiIndex = parseInt(Math.random() * 3)
        const url = "https://api-testnet.polygonscan.com/api";
        const params = {
          "module":"account",
          "action":"txlist",
          "address": address,
          "startblock": 0,
          "endblock":99999999,
          "page" : page,
          "offset": 1000,
          "sort":"desc",
          "apikey": apiKeys[apiIndex]
        }
        const method = "get";

        console.log("url:", url)
        console.log("method:", method);
        console.log("params:", params)
        const resp = await fetch(urlAppendParams(url, params) ,
          {
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json'
            },
          }).then((response) => response.json());
       
        if (!resp.result || Array.isArray(resp.result) == false) {
          return transactions
        }
        const result = Array(...resp.result);
        const todayIndex = result.findIndex((item) => isToday(parseInt(item.timeStamp) * 1000));
        if (todayIndex == -1 && page == null) {
          return transactions
        } else {
          const notTodayIndex = result.findIndex((item) => !isToday(parseInt(item.timeStamp) * 1000));
          if (notTodayIndex == -1) {
            transactions.push(...result)
            await randomTimeout();
            return await getTodayTransactions(page + 1, transactions)
          } else {
            if (notTodayIndex != 0) {
              const values = result.slice(0, notTodayIndex);
              transactions.push(...values)
            }
            console.log("transactions:",transactions);
            return transactions
          }
        }
      }
      const checkTransactions = (transactions, maxValueEth) => {
        const sendTransactions = transactions.filter((item) => item.from == address.toLowerCase());
        const addValue = (total, transaction) => {
          return total.add(ethers.BigNumber.from(transaction.value))
        }
        const total = sendTransactions.reduce(addValue, ethers.BigNumber.from(0))
        const eth = ethers.utils.formatEther(total)
        console.log("total:", eth);
        console.log("max:", maxValueEth);
        return maxValueEth > parseFloat(eth)
      }

      await randomTimeout();
      const transactions = await getTodayTransactions(null, [], 1);
      const res = checkTransactions(transactions, maxValueEth);
      return res
    };

    const res = await go();
    if (res == false) {
        throw Error("Exceeded the daily limit");
    }
    """
    }
    
}



