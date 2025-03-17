package funding.funding.controller;

import funding.funding.model.service.MainPageServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/main")
@RequiredArgsConstructor
public class MainPageController {

    private final MainPageServiceImpl mainPageService;

    @GetMapping("/top-funding")
    public ResponseEntity<?> getTopFundingList() {
        return ResponseEntity.ok(mainPageService.getTopFundingList());
    }


    @GetMapping("/total-fund")
    public ResponseEntity<Long> getTotalFund() {
        return ResponseEntity.ok(mainPageService.getTotalFund());
    }
}
