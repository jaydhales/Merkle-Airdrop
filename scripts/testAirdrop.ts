import { AddressLike, BytesLike } from "ethers";
import { ethers } from "hardhat";

interface WinnerData {
  winner: AddressLike;
  hash: BytesLike;
  winnerProof: BytesLike[];
}

const testAirdrop = async () => {
  const _duration = 86400;
  const _proof =
    "0x0f8c0b2dfa7ae154c74465bbc05a9a8d66a56a9f68755a0c57e1637f708f9874";
  const winnerStruct: WinnerData = {
    winner: "0x001daa61eaa241a8d89607194fc3b1184dcb9b4c",
    hash: "0xd13f963341f5ae2d93c896176514d94e76bd46d5f4f40482c528a79afaa9e8d1",
    winnerProof: [
      "0x5ed7b9969bdfb4debe5cbbaf32deeb08c2f83ef90607e2790a9e00a38743f768",
      "0x4db3bf69a3ab2126cb28603ae23f83b728b0222835581003e49aecf9d2b5c48b",
      "0x4ef68d9190ad531cfb5e09e2af2626b58c2e20f8f6c615212f13ace8c37d5e79",
    ],
  };

  const airdropContract = await ethers.deployContract("Airdrop");
  await airdropContract.waitForDeployment();

  await airdropContract.createAirdrop("Jay's Drop", _duration);

  console.log({ createdDrop: await airdropContract.drops(0) });

  await airdropContract.activateAirDrop(0, _proof);

  console.log({ createdDrop: await airdropContract.drops(0) });

  await airdropContract.claim(winnerStruct, 0);
};

testAirdrop().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
