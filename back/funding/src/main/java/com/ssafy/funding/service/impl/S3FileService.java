package com.ssafy.funding.service.impl;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.ssafy.funding.common.exception.CustomException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

import static com.ssafy.funding.common.response.ResponseCode.FAIL_FILE_DELETE;
import static com.ssafy.funding.common.response.ResponseCode.FAIL_FILE_UPLOAD;

@Component
@RequiredArgsConstructor
public class S3FileService {

    private final AmazonS3 amazonS3;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;


    public String uploadFile(MultipartFile file, String folderName) {
        if (file == null || file.isEmpty()) return null;

        try {
            String fileName = generateFileName(folderName, file.getOriginalFilename());
            ObjectMetadata metadata = createMetadata(file);
            amazonS3.putObject(bucket, fileName, file.getInputStream(), metadata);
            return amazonS3.getUrl(bucket, fileName).toString();
        } catch (IOException e) {
            throw new CustomException(FAIL_FILE_UPLOAD);
        }
    }

    public List<String> uploadFiles(List<MultipartFile> files, String folderName) {
        if (files == null || files.isEmpty()) return List.of();

        return files.stream()
                .map(file -> uploadFile(file, folderName))
                .collect(Collectors.toList());
    }

    public void deleteFile(String fileUrl) {
        if (fileUrl == null || fileUrl.isBlank()) return;

        String key = extractKeyFromUrl(fileUrl);
        if (amazonS3.doesObjectExist(bucket, key)) {
            amazonS3.deleteObject(bucket, key);
        } else {
            throw new CustomException(FAIL_FILE_DELETE);
        }
    }
    public void deleteFiles(List<String> fileUrls) {
        if (fileUrls == null || fileUrls.isEmpty()) return;
        fileUrls.forEach(this::deleteFile);
    }

    private String generateFileName(String folderName, String originalFilename) {
        return folderName + "/" + System.currentTimeMillis() + "_" + originalFilename;
    }

    private ObjectMetadata createMetadata(MultipartFile file) {
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());
        return metadata;
    }

    private String extractKeyFromUrl(String fileUrl) {
        return fileUrl.replace("https://" + bucket + ".s3.ap-northeast-2.amazonaws.com/", "");
    }
}
