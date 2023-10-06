import MerkleTree from "merkletreejs";
import csv from "csv-parser";
import * as fs from "fs";
import path from "path";
import { solidityPackedKeccak256, keccak256 } from "ethers";

//This might not be used

export interface AddressProof {
  leaf: string;
  proof: string[];
}

export interface Data {
  // hash?: string;
  address: string;
  amount: number;
}

const csvfile = path.join(__dirname, "userdata/data.csv");

async function generateMerkleTree(csvFilePath: string): Promise<void> {
  const data: Data[] = [];

  // Read the CSV file and store the data in an array
  await new Promise((resolve, reject) => {
    fs.createReadStream(csvFilePath)
      .pipe(csv())
      .on("data", (row: Data) => {
        data.push(row);
      })
      .on("end", resolve)
      .on("error", reject);
  });
  let leaf: string;
  let leaves: string[] = [];
  // Hash the data using the Solidity keccak256 function
  for (const row of data) {
    leaf = solidityPackedKeccak256(
      ["address", "uint256"],
      [row.address, row.amount]
    );
    leaves.push(leaf);
  }

  // Create the Merkle tree
  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
  const addressProofs: { [address: string]: AddressProof } = {};
  data.forEach((row, index) => {
    const proof = tree.getProof(leaves[index]);
    addressProofs[row.address] = {
      leaf: "0x" + leaves[index].toString(),
      proof: proof.map((p) => "0x" + p.data.toString("hex")),
    };
  });

  // Write the Merkle tree and root to a file
  await new Promise<void>((resolve, reject) => {
    fs.writeFile("merkle_tree.json", JSON.stringify(addressProofs), (err) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });

  // Write a JSON object mapping addresses to data to a file
  const addressData: { [address: string]: Data } = {};
  data.forEach((row, index) => {
    addressData[index] = row;
  });

  await new Promise<void>((resolve, reject) => {
    fs.writeFile("address_data.json", JSON.stringify(addressData), (err) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
  console.log("0x" + tree.getRoot().toString("hex"));
}

generateMerkleTree(csvfile).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
