const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand
} = require("@aws-sdk/client-s3");

const sharp = require("sharp");

const s3 = new S3Client({});

exports.handler = async (event) => {
  const batchItemFailures = [];

  for (const sqsRecord of event.Records || []) {
    try {
      const message = JSON.parse(sqsRecord.body);

      for (const s3Record of message.Records || []) {
        const bucket = s3Record.s3.bucket.name;

        const key = decodeURIComponent(
          s3Record.s3.object.key.replace(/\+/g, " ")
        );

        if (!key.startsWith("uploads/")) {
          continue;
        }

        const object = await s3.send(
          new GetObjectCommand({
            Bucket: bucket,
            Key: key
          })
        );

        const inputBuffer = await streamToBuffer(object.Body);

        const circleMask = Buffer.from(`
          <svg width="40" height="40">
            <circle cx="20" cy="20" r="20" fill="white"/>
          </svg>
        `);

        const processedImage = await sharp(inputBuffer)
          .resize(40, 40, {
            fit: "cover",
            position: "centre"
          })
          .composite([
            {
              input: circleMask,
              blend: "dest-in"
            }
          ])
          .png()
          .toBuffer();

        const fileName = key
          .split("/")
          .pop()
          .replace(/\.[^/.]+$/, "");

        const processedKey =
          `${process.env.PROCESSED_PREFIX}${fileName}_circular.png`;

        await s3.send(
          new PutObjectCommand({
            Bucket: process.env.S3_BUCKET,
            Key: processedKey,
            Body: processedImage,
            ContentType: "image/png"
          })
        );

        console.log(`Imagen procesada: ${processedKey}`);
      }
    } catch (error) {
      console.error("Error procesando mensaje:", error);

      batchItemFailures.push({
        itemIdentifier: sqsRecord.messageId
      });
    }
  }

  return {
    batchItemFailures
  };
};

async function streamToBuffer(stream) {
  if (stream.transformToByteArray) {
    return Buffer.from(await stream.transformToByteArray());
  }

  const chunks = [];

  for await (const chunk of stream) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks);
}