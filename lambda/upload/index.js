const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const Busboy = require("busboy");
const { v4: uuidv4 } = require("uuid");

const s3 = new S3Client({});

const MAX_FILE_SIZE = 10 * 1024 * 1024;

const ALLOWED_TYPES = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/gif": "gif",
  "image/webp": "webp"
};

exports.handler = async (event) => {
  try {
    const contentType =
      event.headers?.["content-type"] ||
      event.headers?.["Content-Type"] ||
      "";

    let image;

    if (contentType.includes("multipart/form-data")) {
      image = await parseMultipart(event, contentType);
    } else if (contentType.includes("application/json")) {
      image = parseJson(event);
    } else {
      return response(415, {
        message: "Tipo de contenido no soportado"
      });
    }

    if (!ALLOWED_TYPES[image.contentType]) {
      return response(400, {
        message: "Formato no permitido. Use jpg, png, gif o webp"
      });
    }

    if (image.buffer.length > MAX_FILE_SIZE) {
      return response(400, {
        message: "La imagen supera el tamaño máximo de 10 MB"
      });
    }

    const extension = ALLOWED_TYPES[image.contentType];

    const key = `${process.env.UPLOAD_PREFIX}${uuidv4()}.${extension}`;

    await s3.send(
      new PutObjectCommand({
        Bucket: process.env.S3_BUCKET,
        Key: key,
        Body: image.buffer,
        ContentType: image.contentType
      })
    );

    return response(201, {
      message: "Imagen cargada correctamente",
      key
    });
  } catch (error) {
    console.error("Upload error:", error);

    return response(500, {
      message: "Error al procesar la imagen"
    });
  }
};

function parseJson(event) {
  const bodyBuffer = event.isBase64Encoded
    ? Buffer.from(event.body || "", "base64")
    : Buffer.from(event.body || "", "utf8");

  const body = JSON.parse(bodyBuffer.toString("utf8"));

  let base64 = body.imageBase64 || body.image;

  if (!base64) {
    throw new Error("No se encontró la imagen en la solicitud");
  }

  let contentType = body.contentType;

  const dataUrl = base64.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/);

  if (dataUrl) {
    contentType = dataUrl[1];
    base64 = dataUrl[2];
  }

  if (!contentType) {
    throw new Error("Debe especificarse el contentType de la imagen");
  }

  return {
    buffer: Buffer.from(base64, "base64"),
    contentType
  };
}

function parseMultipart(event, contentType) {
  return new Promise((resolve, reject) => {
    const body = event.isBase64Encoded
      ? Buffer.from(event.body || "", "base64")
      : Buffer.from(event.body || "", "binary");

    const busboy = Busboy({
      headers: {
        "content-type": contentType
      },
      limits: {
        fileSize: MAX_FILE_SIZE,
        files: 1
      }
    });

    let result;
    let fileTooLarge = false;

    busboy.on("file", (fieldName, file, info) => {
      const chunks = [];

      file.on("data", (chunk) => {
        chunks.push(chunk);
      });

      file.on("limit", () => {
        fileTooLarge = true;
      });

      file.on("end", () => {
        result = {
          buffer: Buffer.concat(chunks),
          contentType: info.mimeType
        };
      });
    });

    busboy.on("finish", () => {
      if (fileTooLarge) {
        reject(new Error("La imagen supera los 10 MB"));
        return;
      }

      if (!result) {
        reject(new Error("No se encontró ninguna imagen"));
        return;
      }

      resolve(result);
    });

    busboy.on("error", reject);

    busboy.end(body);
  });
}

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "content-type": "application/json"
    },
    body: JSON.stringify(body)
  };
}