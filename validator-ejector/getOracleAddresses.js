import dotenv from "dotenv";
import fs from "fs";
import { ethers } from "ethers";

dotenv.config();

// Environment variables
const executionNode = process.env.EXECUTION_NODE;
const hashConsensusContract = process.env.HASH_CONSENSUS_CONTRACT;
const oracleListFilePath = process.env.ORACLE_LIST_FILE_PATH;
// The format is:
// '["0x12A1D74F8697b9f4F1eEBb0a9d0FB6a751366399","0xD892c09b556b547c80B7d8c8cB8d75bf541B2284","0xf7aE520e99ed3C41180B5E12681d31Aa7302E4e5"]'

// ABI for the getMembers() function
const ABI = [
  {
    constant: true,
    inputs: [],
    name: "getMembers",
    outputs: [
      {
        name: "addresses",
        type: "address[]",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
];

async function getMembers() {
  console.log(
    `[INFO] Retrieving allowed oracle addresses from hash consensus smart contract ${hashConsensusContract}...`
  );

  try {
    const provider = new ethers.providers.JsonRpcProvider(executionNode);

    const contract = new ethers.Contract(hashConsensusContract, ABI, provider);

    // getMembers function returns an array of allowed oracle addresses
    const members = await contract.getMembers();
    console.log("[INFO] Allowed oracle addresses: ", members);

    fs.writeFileSync(oracleListFilePath, JSON.stringify(members));
  } catch (error) {
    console.error("[ERROR] Could not fetch allowed oracles:", error);
    console.log("[INFO] Using default oracle addresses...");
  }
}

getMembers();