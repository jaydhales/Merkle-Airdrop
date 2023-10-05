import MerkleTree from "merkletreejs";
import path from "path";
import * as fs from "fs";
import csv from "csv-parser";
import { Data, generateAirdropCSV, getPath } from "./addAirdropInfo";
import { solidityPackedKeccak256, keccak256 } from "ethers";
import { AddressProof } from "./generateProof";

const winnersFile = path.join(__dirname, "userdata/data.csv");

const generateAirdropTree = async (airdropName: string, airdropId: number) => {
  const data: Data[] = [];
  //first generate the election csv data
  const csvFile = await generateAirdropCSV(winnersFile, airdropName, airdropId);

  await new Promise((resolve, reject) => {
    fs.createReadStream(csvFile)
      .pipe(csv())
      .on("data", (row: Data) => {
        data.push(row);
      })
      .on("end", resolve)
      .on("error", reject);
  });
  let leaf: string;
  let leaves: string[] = [];

  for (const row of data) {
    leaf = solidityPackedKeccak256(
      ["address", "bytes32", "uint256"],
      [row.address, row.hash, row.airdropId]
    );
    leaves.push(leaf);
  }

  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
  const addressProofs: { [address: string]: AddressProof } = {};
  data.forEach((row, index) => {
    const proof = tree.getProof(leaves[index]);
    addressProofs[row.address] = {
      leaf: "0x" + leaves[index].toString(),
      proof: proof.map((p) => "0x" + p.data.toString("hex")),
    };
  });

  await new Promise<void>((resolve, reject) => {
    fs.writeFile(
      `${getPath(csvFile)}/tree.json`,
      JSON.stringify(addressProofs),
      (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      }
    );
  });

  const addressData: { [address: string]: Data } = {};
  data.forEach((row) => {
    addressData[row.address] = row;
  });

  await new Promise<void>((resolve, reject) => {
    fs.writeFile(
      `${getPath(csvFile)}/data.json`,
      JSON.stringify(addressData),
      (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      }
    );
  });
  console.log("0x" + tree.getRoot().toString("hex"));
};

generateAirdropTree("Jay's-Airdrop", 0).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
