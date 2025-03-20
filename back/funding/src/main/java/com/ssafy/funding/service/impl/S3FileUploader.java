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

import static com.ssafy.funding.common.response.ResponseCode.FAIL_FILE_UPLOAD;

@Component
@RequiredArgsConstructor
public class S3FileUploader {

    private final AmazonS3 amazonS3;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;


    public String uploadFile(MultipartFile file, String folderName) {
        try {
            String fileName = folderName + "/" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(file.getSize());
            metadata.setContentType(file.getContentType());

            amazonS3.putObject(bucket, fileName, file.getInputStream(), metadata);
            return amazonS3.getUrl(bucket, fileName).toString();
        } catch (IOException e) {
            throw new CustomException(FAIL_FILE_UPLOAD);
        }
    }

    public List<String> uploadFiles(List<MultipartFile> files, String folderName) {
        return files.stream()
                .map(file -> uploadFile(file, folderName))
                .collect(Collectors.toList());
    }
}
