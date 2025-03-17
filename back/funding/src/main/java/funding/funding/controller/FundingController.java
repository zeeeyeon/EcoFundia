package funding.funding.controller;

import funding.funding.model.entity.Funding;
import funding.funding.model.service.FundingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/funding")
@RequiredArgsConstructor
public class FundingController {

    private final FundingService fundingService;


    @GetMapping
    public ResponseEntity<Object> getAllfunding() {
        return ResponseEntity.ok(fundingService.getAllFunding());
    }

    @GetMapping("/{fundingId}")
    public ResponseEntity<Object> getFunding(@PathVariable int fundingId) {
        Funding funding = fundingService.getFundingById(fundingId);

        if (funding != null) {
            return ResponseEntity.ok(funding);
        } else {
            return ResponseEntity.notFound().build();
        }

    }

}
