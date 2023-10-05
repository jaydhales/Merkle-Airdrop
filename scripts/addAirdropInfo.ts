import csv = require("csv-parser");
const createCsvWriter = require("csv-writer").createObjectCsvWriter;
import * as fs from "fs";
import path = require("path");

export interface Data {
  hash?: string;
  address: string;
  airdropId?: number;
}

//helper function to help generate election tries
export async function generateAirdropCSV(
  csvFilePath: string,
  airdropName: string,
  airdropId: number
): Promise<string | ""> {
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
  if (data.length > 0 && "airdropId" in data[0]) {
    console.log("The airdropId column already exists. Exiting the function.");
    return "";
  }

  // Hash the data using the Solidity keccak256 function
  for (const row of data) {
    row.airdropId = airdropId;
  }
  let toFile: string = "";
  // Write the hashed data back to the CSV file
  await new Promise((resolve, reject) => {
    fs.mkdirSync(`scripts/airdropTree/${airdropName}`);
    toFile = `scripts/airdropTree/${airdropName}/electionData.csv`;
    const csvWriter = new createCsvWriter({
      path: toFile,
      header: [
        { id: "address", title: "address" },
        { id: "hash", title: "hash" },
        { id: "airdropId", title: "airdropId" },
      ],
      fieldDelimiter: ",",
      recordDelimiter: "\n",
      quoteStrings: '"',
      escaping: true,
    });
    csvWriter.writeRecords(data).then(resolve).catch(reject);
  });
  return toFile;
}

export function getPath(str: string): string {
  return path.dirname(str);
}
